#!/usr/bin/perl
use strict;
use warnings;
use IO::File;
use constant DEBUG => 0;
use constant VDEBUG => 0;

my @allurls;

# input makefile for processing
my $filename = shift;

my $package = ""; # current processing package
my $targetbase; # .deps file for current package without any suffixes
my $target; # base .deps file for current processing package
my $version; # version of current processing package
my $dir; # dir for current processing package

my $line = 0; # processing line, for debug

# command sytax definitions
my $supported_protocols = "https|http|ftp|file|git|svn|local|localwork";
# commands executed at prepare time
my $make_commands = "nothing|extract|dirextract|patch(-(\\d+))?|pmove|premove|plink|pdircreate";
# commands executed at install time
my $install_commands = "install|install_file|install_bin|make|move|remove|mkdir|link";

#my $patchesdir .= "\$(buildprefix)/Patches";
my $patchesdir .= "\$(srcdir)/make";

sub load ($$);

# File preprocessor begins.
sub load ($$)
{
  my ( $filename, $ignore ) = @_;

  my $fh = new IO::File $filename;

  if ( ! $fh )
  {
    return undef if $ignore;
    die "can't open $filename\n";
  }

  my $foutname;
  ($foutname = $filename) =~ s#(.*).pre#$1#;
  print "output to $foutname\n";
  open FILE, "+>", "$foutname";
  
  my $start = 0; # is we in rule.
  my $foundrule = 0; # is there any rule for current package

  while ( <$fh> )
  {
    $line += 1;
    if ( $_ =~ m#^\]\]rule\s*$# )
    {
      if ($package eq "") { die "$line: rule]] outside of package[[ ]]package is forbidden" }
      $start = 0;
      next;
    }
    if ( $_ =~ m#^rule\[\[\s*$# )
    {
      if ($package eq "") { die "$line: rule[[ outside of package[[ ]]package is forbidden" }
      $start = 1;
      # call begin only once
      if($foundrule == 0) {
        process_begin();
        $foundrule = 1;
      }
      next;
    }

    if ($_ =~ m#^package\[\[# )
    {
      if ( $_ =~ m#^package\[\[\s*([\w_]+)\s*$# ) {
        if ($package ne "") { die "$line: recursive package[[ command is not supported" }
        if ($start != 0) {die "$line: commands overlap" }
        $package = $1;
        $foundrule = 0;
        print "==> $package" . "\n" if DEBUG;
        my $dashpackage = $package;
        $dashpackage =~ s#_#\-#g;
        print FILE "PN_$package := $dashpackage\n";
        next;
      } else {
        die "$line: bad package[[ command format: " . $_;
      }
    }
    if ( $_ =~ m#^\]\]package# )
    {
      if ($package ne "") {
        $package = "";
        if ($start != 0) {die "$line: commands overlap" }
        if ($foundrule == 0) {die "$line: package without rule is inavlid\nadd empty block\nrule[[\n]]rule" }
      } else {
        die "$line: ]]package closure bracket doesn't match";
      }
      next;
    }
    if ($package ne "") {
      # $$ escapes $
      # Replace ${P} with package
      $_ =~ s/(?<!\$)\${P}/$package/g;
      # Replace ${VARIABLE} with $(package_VARIABLE)
      $_ =~ s/(?<!\$)\${([\w\d_]+)}/\$\($1_$package\)/g;
    }
    #don't touch Makefile conditional in rule[[
    if (not $start or ($_ =~ m#^(ifdef |ifndef |ifeq |ifneq |else|endif)#) )
    {
      print FILE $_;
      next;
    }
    # === rule preprocessor begin ==

    # remove comments
    $_ =~ s/#.*$//;
    # skip empty lines
    if ($_ =~ m#^\s+$#) {
      next;
    }
    chomp $_;
    $_ =~ s/^\s+//; #remove leading spaces
    $_ =~ s/\s+$//; #remove trailing spaces

    process_block($_);

  }
  print "lines $line\n" if DEBUG;
  close FILE;
}

sub process_block ($)
{
  warn "==> $package, $version, $dir  :  $_" if DEBUG;
  my $out;

  $out = process_depends($_);
  print FILE subs_vars("DEPENDS_$package += $out \n") if $out;
  $out = process_prepare($_);
  print FILE subs_vars("PREPARE_$package += $out \n") if $out;
  $out = process_sources($_);
  print FILE subs_vars("SRC_URI_$package += $out \n") if $out;
  $out = process_install($_);
  print FILE subs_vars("INSTALL_$package += $out \n") if $out;
  $out = process_download($_);
  print FILE subs_vars("$out \n") if $out;

  print FILE "\n";
}

sub process_rule($) {

  warn "parse: " . $_ . "\n" if DEBUG;

  my $f = ""; # file from url
  my $l = $_;
  my @l = (); # input list

  if ($l =~ m#\;#)
  {
    @l = split( /;/ , $l );
  } else {
    @l = split( m#:(?!//)# , $l );
  }

  my $protocol = "none";
  my $url = "";
  my $foundurl = 0;
  my @cmd_argv = ();
  my @url_argv = ();
  my $arg;
  while ($arg = shift @l)
  {
    if ( $arg =~ m#^($supported_protocols)://# ) {
      $protocol = $1;
      $url = $arg;
      $foundurl = 1;
      next;
    }
    if($foundurl == 1) {
      push(@url_argv, $arg);
    } else {
      push(@cmd_argv, $arg);
    }
  }
  my $cmd = shift @cmd_argv;
  if (defined($cmd)) {
    if ( $cmd !~ m#^($make_commands|$install_commands)$# ) {
      die "$line: can't recognize command $cmd";
    }
  } else {
    $cmd = "extract";
  }

  if ( $protocol ne "none" )
  {
    my @a = split("/", $url);
    $f = $a[-1];
  }

  my %args = ();
  my @argv = ();

  while(my $arg = shift @url_argv)
  {
    # argument dict
    if ($arg =~ m/(\w+)=(.*)/)
    {
      $args{$1} = $2 ;
      #warn "arg " . $1 . ' = ' . $2 . "\n";
    } else {
    # argument list
      push(@argv, $arg);
      #warn "argv " . $arg . "\n";
    }
  }

  if ($url) {
    if ( $url =~ m#^svn://# )
    {
        $f = $package . ".svn"
    }
    if ( $url =~ m#^file://# )
    {
        $f = $url;
        $f =~ s#^file://##;
        $f = "$patchesdir/$f";
    }
    elsif ( $url =~ m#^localwork://# )
    {
        $f = $url;
        $f =~ s#^localwork://##;
    }
    elsif ( $url =~ m#^($supported_protocols)://# )
    {
        $f = "\$(archivedir)/$f";
    }
  }

  my $urldbg = $url;
  if (not $urldbg) { $urldbg = "none" };
  warn "command $cmd; argv @cmd_argv; url $url; protocol: $protocol; file: $f;\n" if DEBUG;

  return ($protocol, $f, $cmd, $url, \%args, \@cmd_argv, \@argv);
}


sub process_depends ($)
{
  my $output = "";

    my ($p, $f) = process_rule($_);
    return if ( $p eq "none" || $p eq "localwork");

    if ( $p =~ m#^(file)$# or $p =~ m#^($supported_protocols)$#  )
    {
      $output .= "$f ";
    }
    else
    {
      die "can't recognize protocol " . $p;
    }

  return $output;
}

sub process_begin ()
{
  # some common variables
  $targetbase = "\$(DEPDIR_$package)/$package";
  $target  = "\$(TARGET_$package)";
  $dir = "\$(DIR_$package)";
  $version = "\$(PKGV_$package)";

  my $output;
  # make it safe. rm -rf
  $output .= "DIR_$package := \$(if $dir,\$(workprefix)/$dir,\$(workprefix)/$package)" . "\n";

  $output .= "PREPARE_$package = ( rm -rf $dir || /bin/true )" . "\n";
  $output .= "INSTALL_$package = /bin/true" . "\n";
  $output .= "DEPENDS_$package = $targetbase.version_\$(PKGV_$package)-\$(PKGR_$package)" . "\n";
  # remove previous versions so, if you change version back to the previous value it cause rebuild again.
  $output .= "UPDATE_$package = rm -rf $targetbase.version*" . "\n";

  if ($version =~ m#^git|svn$#) {
    my $ret = process_update($version, $dir);
    # in case package is in local sources
    $output .= "UPDATE_$package += && ($ret)" . "\n";
    # list of packages to check for vcs updates
    $output .= "UPDATE_LIST += $targetbase.version_\$(PKGV_$package)-\$(PKGR_$package)" . "\n";
    # get version from vcs
    $output .= "AUTOPKGV_$package = \$(eval export PKGV_$package = \$(shell cd $dir && \$(${version}_version)))" . "\n";
  } else {
    $output .= "UPDATE_$package += && touch \$\@" . "\n";
  }

  $output .= "\n";
  $output .= "$targetbase.version_%:"    . "\n";
  $output .= "\t\$(UPDATE_$package)" . "\n";

  $output .= "\n";
  $output .= "$target.clean_prepare:"      . "\n";
  $output .= "\trm -f $target.do_prepare"  . "\n";
  $output .= "$target.clean_compile:"      . "\n";
  $output .= "\trm -f $target.do_compile"  . "\n";
  $output .= "$target.clean:"              . "\n";
  $output .= "\trm -f $target"             . "\n";

  print FILE subs_vars($output);
  print FILE "\n"
}


sub process_prepare ($)
{

  my $output = "";
  my $outpost = "";

    my ($p, $f, $cmd, $url, $opts_ref, $argv_ref) = process_rule($_);
    my %opts = %$opts_ref;
    my @args = @$argv_ref;

    # $args[0] equals $cmd.
    unshift(@args, $cmd);

    my $subdir = "";
    $subdir = "/" . $opts{"sub"} if $opts{"sub"};

    if ( $cmd !~ m#^($make_commands)$# )
    {
      return;
    }

    $output .= "&& cd \$(workprefix) && ";

    if ( ($cmd eq "extract" or $cmd eq "dirextract") and $p !~ m#(git|svn)#)
    {
      if ( $cmd eq "dirextract" ) {
        $output .= "( mkdir $dir || /bin/true ) && ";
        $output .= "( cd $dir; ";
      }
      if ( $f =~ m#\.tar\.bz2$# )
      {
        $output .= "bunzip2 -cd " . $f . " | tar -x";
      }
      elsif ( $f =~ m#\.tar\.gz$# )
      {
        $output .= "gunzip -cd " . $f . " | TAPE=- tar -x";
      }
      elsif ( $f =~ m#\.tgz$# )
      {
        $output .= "gunzip -cd " . $f . " | TAPE=- tar -x";
      }
      elsif ( $f =~ m#\.tar\.xz$# )
      {
      $output .= "tar -xJf " . $f;
      }
      elsif ( $f =~ m#\.exe$# )
      {
        $output .= "cabextract " . $f;
      }
      elsif ( $f =~ m#\.zip$# )
      {
        $output .= "unzip " . $f;
      }
      elsif ( $f =~ m#\.(src|sh4)\.rpm$# )
      {
        $output .= "rpm2cpio " . $f . " | cpio -dimv ";
      }
      else
      {
        die "can't recognize type of archive \"$f\"";
      }
      if ( $cmd eq "dirextract" ) {
        $output .= " )";
      }
    }
    elsif ( $p eq "svn" )
    {
      if ( not $opts{"r"} )
      {
         $output .= "(cd " . $f . " && svn update) && ";
      }
      $output .= "(cd " . $f . "; svn up -r " . $opts{"r"} . "; cd -) && " if $opts{"r"};
      $output .= "cp -a " . $f . $subdir . " " . $dir;
    }
    elsif ( $p eq "git" )
    {
      my $branch = "master";
      my $rev;
      $branch = $opts{"b"} if $opts{"b"};
      $rev = $opts{"r"} if $opts{"r"};

      # -- pull changes from remote --
      my $pullcmd;
      $pullcmd  = "(cd $f && git fetch && git checkout $branch && git pull --rebase origin $branch && cd -)";
      $pullcmd .= " && (cd $f && git checkout $rev && cd -)" if $rev;
      $output .= "$pullcmd && cp -a $f/$subdir $dir";

      # -- pull and then version touch --
      # do after default UPDATE_ command, so do touch again (override)
      my $ret = process_update($version, $f);
      $outpost .= "UPDATE_$package += && ( [ ! -d $f ] || $pullcmd ) && ($ret)";
    }
    elsif ( $cmd eq "nothing" )
    {
      $output .= "cp -a $f $dir";
    }
    elsif ( $cmd =~ m/patch(-(\d+))?/ )
    {
      shift @args;
      my $patch;
      if ($2) {
        $patch = "patch -p$2 ";
      } else {
        $patch = "patch -p1 ";
      }
      $patch .= join " ", @args;

      if ( $f =~ m#\.bz2$# )
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; bunzip2 -cd " . $f . " | $patch )";
      }
      elsif ( $f =~ m#\.deb\.diff\.gz$# )
      {
        $output .= "( cd " . $dir . "; gunzip -cd " . $f . " | $patch )";
      }
      elsif ( $f =~ m#\.gz$# )
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; gunzip -cd " . $f . " | $patch )";
      }
      elsif ( $f =~ m#\.spec\.diff$# )
      {
        $output .= "( cd SPECS && $patch < " . $f . " )";
      }
      else
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; $patch < " . $f . " )";
      }
    }
    elsif ( $cmd eq "pmove" )
    {
      $output .= "mv " . $args[1] . " " . $args[2];
    }
    elsif ( $cmd eq "premove" )
    {
      $output .= "( rm -rf " . $args[1] . " || /bin/true )";
    }
    elsif ( $cmd eq "plink" )
    {
      $output .= "( ln -sf " . $args[1] . " " . $args[2] . " || /bin/true )";
    }
    elsif ( $cmd eq "plndir" )
    {
      $output .= "lndir " . $args[1] . " " . $args[2];
    }
    elsif ( $cmd eq "pdircreate" )
    {
      $output .= "( mkdir -p " . $args[1] . " )";
    }
    else
    {
      die "can't recognize command $cmd";
    }

  $output .= "\n$outpost" if $outpost;
  return $output;
}

sub process_update ($$)
{
  my ( $vcs, $d ) = @_;
  my $out;
  # if directory exists launch touch command, return 1 if command failed
  # if directory doesn't exists return 0
  $out = "[ ! -d $d ] || (touch \$\@ -d `cd $d && \$(${vcs}_version_time)` && echo \$\@: `date -r \$\@`)";
  return $out;
}

sub process_install ($)
{

  my ($p, $f, $cmd, $url, $opts_ref, $argv_ref) = process_rule($_);
  my @argv = @$argv_ref;

  if ( $cmd !~ m#^($install_commands)$# )
  {
    return;
  }

  my $output = "&& ";

  if ( $cmd =~ m#install_file|install_bin# )
  {
    $cmd =~ y/a-z/A-Z/ ;
    $output .= "\$\($cmd\) $f @argv";
  }
  elsif ( $cmd eq "make" )
  {
    $output .= "\$\(MAKE\) " . join " ", @argv;
  }
  elsif ( $cmd eq "install" )
  {
    if($f ne "") {
      $output .= "\$\(INSTALL\) $f " . join " ", @argv;
    } else {
      $output .= "\$\(INSTALL\) " . join " ", @argv;
    }
  }
  elsif ( $cmd eq "move" )
  {
    $output .= "mv " . join " ", @argv;
  }
  elsif ( $cmd eq "remove" )
  {
    $output .= "rm -rf " . join " ", @argv;
  }
  elsif ( $cmd eq "mkdir" )
  {
    $output .= "mkdir -p " . join " ", @argv;
  }
  elsif ( $cmd eq "link" )
  {
    $output .= "ln -sf " . join " ", @argv;
  }
=pod
  elsif ( $cmd =~ m/^rewrite-(libtool|pkgconfig|dependency)/ )
  {
    $output .= "perl -pi -e \"s,^libdir=.*\$\$,libdir='TARGET/usr/lib',\" ". join " ", @argv if $1 eq "libtool";
    $output .= "perl -pi -e \"s, /usr/lib, TARGET/usr/lib,g if /^dependency_libs/\"  ". join " ", @argv if $1 eq "dependency";
    $output .= "perl -pi -e \"s,^prefix=.*\$\$,prefix=TARGET/usr,\" " . join " ", @argv if $1 eq "pkgconfig";
  }
=cut
  else
  {
    die "can't recognize rule \"$cmd\"";
  }

  return $output;
}

=pod
sub process_uninstall_rule ($)
{
  my $rule = shift;
  my ($p, $f, $cmd) = process_rule($rule);
  
  if ( $cmd =~ m#$make_commands# )
  {
    return "";
  }

  @_ = split ( /:/, $rule );
  $_ = shift @_;

  my $output = "";

  if ( $_ eq "make" )
  {
    $output .= "\$\(MAKE\) " . join " ", @_;
  }
  elsif ( $_ eq "install" )
  {
    $output .= "\$\(INSTALL\) " . join " ", @_;
  }
  elsif ( $_ eq "rpminstall" )
  {
    $output .= "rpm \${DRPM} --ignorearch -Uhv RPMS/sh4/" . join " ", @_;
  }
  elsif ( $_ eq "shellconfigdel" )
  {
    $output .= "export HCTDUNINST \&\& HOST/bin/target-shellconfig --del " . join " ", @_;
  }
  elsif ( $_ eq "initdconfigdel" )
  {
    $output .= "export HCTDUNINST \&\& HOST/bin/target-initdconfig --del " . join " ", @_;
  }
  elsif ( $_ eq "move" )
  {
    $output .= "mv " . join " ", @_;
  }
  elsif ( $_ eq "remove" )
  {
    $output .= "rm -rf " . join " ", @_;
  }
  elsif ( $_ eq "link" )
  {
    $output .= "ln -sf " . join " ", @_;
  }
  elsif ( $_ eq "archive" )
  {
    $output .= "TARGETNAME-ar cru " . join " ", @_;
  }
  elsif ( $_ =~ m/^rewrite-(libtool|pkgconfig)/ )
  {
    $output .= "perl -pi -e \"s,^libdir=.*\$\$,libdir='TARGET/lib',\"  ". join " ", @_ if $1 eq "libtool";
    $output .= "perl -pi -e \"s,^prefix=.*\$\$,prefix=TARGET,\" " . join " ", @_ if $1 eq "pkgconfig";
  }
  else
  {
    die "can't recognize rule \"$rule\"";
  }

  return $output;
}
=cut

sub process_sources ($)
{
  my $output = "";

    my ($p, $f, $cmd, $url, $opts_ref) = process_rule($_);
    my %opts = %$opts_ref;
    return if ( $p eq "none" );
    my $rev = "";
    $rev = ":r$opts{'r'}" if $opts{"r"};
    $output .= "$url$rev ";

  return "$output"
}

sub process_download ($)
{

    my $head;
    my $output = "";

    my ($p, $f, $cmd, $url, $opts_ref) = process_rule($_);
    my %opts = %$opts_ref;
    return if ( $p eq "file" || $p eq "none" || $p eq "local" || $p eq "localwork");

    $f =~ s/\\//;

    my $file = $f;
    $file =~ s/\$\(archivedir\)//;

    # omit duplicating urls
    my $suburl = subs_vars($url);
    if( $suburl ~~ @allurls )
    {
       #warn $suburl . "\n";
       next;
    }
    push(@allurls, $suburl);
    
    #warn "download: " . $url . "\n";
    
    $head .= " " . $f;
    $output .= "$f :\n";

    if ( $url =~ m#^ftp://# )
    {
      $output .= "\t\$(WGET) \$(archivedir) $url";
    }
    elsif ( $url =~ m#^http://# )
    {
      $output .= "\t\$(WGET) \$(archivedir) $url";
    }
    elsif ( $url =~ m#^https://# )
    {
      $output .= "\t\$(WGET) \$(archivedir) $url";
    }
    elsif ( $url =~ m#^svn://# )
    {
      my $tmpurl = $url;
      $url =~ s#svn://#http://# ;
      $output .= "\tsvn checkout $url $f";
    }
    elsif ( $url =~ m#^git://# )
    {
      my $tmpurl = $url;
      $tmpurl =~ s#git://#$opts{"protocol"}://#  if $opts{"protocol"} ;
      $tmpurl =~ s#ssh://#git\@# if $opts{"protocol"} eq "ssh";
      $output .= "\tgit clone $tmpurl  $f";
      $output .= " -b " . $opts{"b"} if $opts{"b"};
    }

    $output .= "\n\n";
    return "$output"
}


sub subs_vars($)
{
  my $output = shift;
  $output =~ s#PKDIR#\$\(PKDIR\)#g;
#  $output =~ s#\{PV\}#$version#g;
#  $output =~ s#\{PF\}#../Files/$package#g;
#  my $dashpackage = $package;
#  $dashpackage =~ s#_#\-#g;
#  $output =~ s#\{PN\}#$dashpackage#g;
  return $output
}

load ( $filename, 0 );
