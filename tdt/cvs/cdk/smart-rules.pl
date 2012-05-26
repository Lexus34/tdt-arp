#!/usr/bin/perl
use strict;
use warnings;
use IO::File;

my $version;
my @allurls;

my $filename = shift;
my $allout = "";
my $package = ""; # current processing package

my $supported_protocols = "http|ftp|file|git|svn";
my $make_commands = "nothing|extract|dirextract|patch(time)?(-(\\d+))?|pmove|premove|plink|pdircreate";

my %ruletypes =
(
  make => \&process_make,
  download => \&process_download,
  install => \&process_install,
);


sub load ($$);

sub load ($$)
{
  my ( $filename, $ignore ) = @_;

  my $fh = new IO::File $filename;

  if ( ! $fh )
  {
    return undef if $ignore;
    die "can't open $filename\n";
  }
  
  my $lines;
  while ( <$fh> )
  {
    $_ =~ s/#.*$//;
    $lines .= $_ if not $_ =~ m#^\s+$#;
  }
  my @lines = split( /;;|\n\n|\n;|;\n/ , $lines);

  foreach ( @lines )
  {
    my @l = split ( /\n|;/ , $_ );
    chomp @l;
    my @rule;
    foreach (@l)
    {
      $_ =~ s/^\s+//; #remove leading spaces
      $_ =~ s/\s+$//; #remove trailing spaces
      push(@rule, $_) if ( $_ ne "" );
    }
    
    #warn "BEGIN package\n" . join(";", @rule) . "\nEND\n";

    if( ($rule[0] eq ">>>" or $rule[0] eq ">>?") and defined $rule[1])
    {
      load ( $rule[1], 0 ) if $rule[0] eq ">>>";
      load ( $rule[1], 1 ) if $rule[0] eq ">>?";
    }
    elsif (defined $rule[0]) {
      $package = shift @rule;
      foreach ( sort keys %ruletypes )
      {
        open FILE, "+>", "ruledir/$_" . "_" . $package;
        $allout = &{$ruletypes{$_}} ($package, \@rule);
        #print "$allout\n";
        print FILE subs_vars($allout);
        close FILE;
      }
    }
  }

}

sub process_rule($) {

  #warn "parse: " . $_ . "\n";

  my $f = "";
  my $l = $_;
  my @l = split( /:/ , $l );

#  s#^(\w+)?:($supported_protocols)://([^:]+):.*$#
  
  my $cmd = shift @l;
  my $p;

  if ( $cmd =~ m#^($supported_protocols)# )
  {
    $p = $cmd;    
    $cmd = "extract";
  }
  elsif ( $cmd =~ m#^($make_commands)$# )
  {
    $p = shift @l;
  }
  
  my $url = shift @l;
  #print "test $url \n";
  if ( not $url or $url !~ m#^//.*# )
  {
    $p = "none";
  }
  else
  {
    $url = $p . ":" . $url;
  }

  if ( $p ne "none" )
  {
    my @a = split("/", $url);
    $f = $a[-1];
  }
  #warn "command: $cmd protocol: $p file: $f\n";

  my %args = ();
  my $arg;
  while($arg = shift @l)
  {
    $args{$1} = $2 if $arg =~ m/(\w+)=(.*)/;
    #warn "arg " . $1 . ' = ' . $2 . "\n";
  }    

  return ($p, $f, $cmd, $url, %args);
}

sub process_make_depends (@)
{
  #return "\"fu\"";
  shift;
  shift;

  my $output = "";

  foreach ( @_ )
  {  
    my ($p, $f) = process_rule($_);
    next if ( $p eq "none" );

    if ( $p =~ m#^(file)$# )
    {
      $output .= "Patches/" . $f . " ";
    }
    elsif ( $p =~ m#^($supported_protocols)$# )
    {
      $output .= "\\\$(archivedir)/" . $f . " ";
    }
    else
    {
      die "can't recognize protocol " . $_;
    }
  }

  return "\"$output\"";
}

sub process_make_dir (@)
{
  return $_[1];
}


sub process_make_prepare (@)
{
  shift;
  my $dir = shift;

  my $output = "( rm -rf " . $dir . " || /bin/true )";

  foreach ( @_ )
  {
    my @args = split( /:/, $_ );
    my ($p, $f, $cmd, $url, %opts) = process_rule($_);
    my $subdir = "";
    $subdir = "/" . $opts{"sub"} if $opts{"sub"};
    local @_ = ($p, $f);

    if ( $cmd eq "nothing" || $cmd !~ m#$make_commands# )
    {
      next;
    }
    
    if ( $output ne "" )
    {
      $output .= " && ";
    }
    
    if ( $cmd eq "rpm" || $cmd eq "extract")
    {
      if ( $_[1] =~ m#\.tar\.bz2$# )
      {
        $output .= "bunzip2 -cd \\\$(archivedir)/" . $_[1] . " | TAPE=- tar -x";
      }
      elsif ( $_[1] =~ m#\.tar\.gz$# )
      {
        $output .= "gunzip -cd \\\$(archivedir)/" . $_[1] . " | TAPE=- tar -x";
      }
      elsif ( $_[1] =~ m#\.tgz$# )
      {
        $output .= "gunzip -cd \\\$(archivedir)/" . $_[1] . " | TAPE=- tar -x";
      }
      elsif ( $_[1] =~ m#\.exe$# )
      {
        $output .= "cabextract \\\$(archivedir)/" . $_[1];
      }
      elsif ( $_[1] =~ m#\.zip$# )
      {
        $output .= "unzip -d $dir \\\$(archivedir)/" . $_[1];
      }
      elsif ( $_[1] =~ m#\.src\.rpm$# )
      {
        $output .= "rpm \${DRPM} -Uhv  \\\$(archivedir)/" . $_[1];
      }
      elsif ( $_[1] =~ m#\.cvs# )
      {
        my $target = $dir;
        if ( @_ > 2 )
        {
          $target = $_[2] 
        }
        $output .= "cp -a \\\$(archivedir)/" . $_[1] . " " . $target;
      }
      elsif ( $p eq "svn" )
      {
        $output .= "cp -a \\\$(archivedir)/" . $_[1] . $subdir . " " . $dir;
      }
      elsif ( $p eq "git" )
      {
        $output .= "cp -a \\\$(archivedir)/" . $_[1] . $subdir . " " . $dir;
      }

      else
      {
        warn "can't recognize type of archive " . $_[1] . " skip";
        $output .= "true";
      }
    }
    elsif ( $cmd eq "dirextract" )
    {
      $output .= "( mkdir " . $dir . " || /bin/true ) && ";
      $output .= "( cd " . $dir . "; ";

      if ( $_[1] =~ m#\.tar\.bz2$# )
      {
        $output .= "bunzip2 -cd \\\$(archivedir)/" . $_[1] . " | tar -x";
      }
      elsif ( $_[1] =~ m#\.tar\.gz$# )
      {
        $output .= "gunzip -cd \\\$(archivedir)/" . $_[1] . " | tar -x";
      }
      elsif ( $_[1] =~ m#\.exe$# )
      {
        $output .= "cabextract \\\$(archivedir)/" . $_[1];
      }
      else
      {
        die "can't recognize type of archive " . $_[1];
      }

      $output .= " )";
    }
    elsif ( $cmd =~ m/patch(time)?(-(\d+))?/ )
    {
      local $_;
      $_ = "-p1 ";
      $_ = "-p$3 " if defined $3;
      $_ .= "-Z " if defined $1;
      if ( $_[1] =~ m#\.bz2$# )
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; bunzip2 -cd \\\$(archivedir)/" . $_[1] . " | patch $_ )";
      }
      elsif ( $_[1] =~ m#\.deb\.diff\.gz$# )
      {
        $output .= "( cd " . $dir . "; gunzip -cd ../Patches/" . $_[1] . " | patch $_ )";
      }
      elsif ( $_[1] =~ m#\.gz$# )
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; gunzip -cd \\\$(archivedir)/" . $_[1] . " | patch $_ )";
      }
      elsif ( $_[1] =~ m#\.spec\.diff$# )
      {
        $output .= "( cd SPECS && patch $_ < ../Patches/" . $_[1] . " )";
      }
      else
      {
        $output .= "( cd " . $dir . " && chmod +w -R .; patch $_ < ../Patches/" . $_[1] . " )";
      }
    }
    elsif ( $cmd eq "rpmbuild" )
    {
      $output .= "rpmbuild \${DRPMBUILD} -bb -v --clean --target=sh4-linux SPECS/stm-" . $f . ".spec ";
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
    elsif ( $cmd eq "pdircreate" )
    {
      $output .= "( mkdir -p" . $args[1] . " )";
    }
    else
    {
      die "can't recognize command @_";
    }
  }

  return "\"$output\"";
}

sub process_make_version (@)
{
  $version = $_[0];
  return $_[0];
}

sub process_make ($$)
{
  #warn $_[0];
  my $package = $_[0];
  my @rules = @{$_[1]};
  my $output = "";

  my %args =
  (
    depends => \&process_make_depends,
    dir => \&process_make_dir,
    prepare => \&process_make_prepare,
    version => \&process_make_version,
    sources => \&process_make_sources,
  );

  foreach ( sort keys %args )
  {
    ( my $tmp = $_ ) =~ y/a-z/A-Z/;
    $output .= $tmp . "_" . $package . "=" . &{$args{$_}} (@rules) . "\n";
  }

  return $output;
}

sub process_install_rule ($)
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
  elsif ( $_ eq "shellconfigadd" )
  {
    $output .= "export HCTDINST \&\& HOST/bin/target-shellconfig --add " . join " ", @_;
  }
  elsif ( $_ eq "initdconfigadd" )
  {
    $output .= "export HCTDINST \&\& HOST/bin/target-initdconfig --add " . join " ", @_;
  }
  elsif ( $_ eq "move" )
  {
    $output .= "mv " . join " ", @_;
  }
  elsif ( $_ eq "remove" )
  {
    $output .= "rm -rf " . join " ", @_;
  }
  elsif ( $_ eq "mkdir" )
  {
    $output .= "mkdir -p " . join " ", @_;
  }
  elsif ( $_ eq "link" )
  {
    $output .= "ln -sf " . join " ", @_;
  }
  elsif ( $_ eq "archive" )
  {
    $output .= "TARGETNAME-ar cru " . join " ", @_;
  }
  elsif ( $_ =~ m/^rewrite-(libtool|pkgconfig|dependency)/ )
  {
    $output .= "perl -pi -e \"s,^libdir=.*\$\$,libdir='TARGET/usr/lib',\" ". join " ", @_ if $1 eq "libtool";
    $output .= "perl -pi -e \"s, /usr/lib, TARGET/usr/lib,g if /^dependency_libs/\"  ". join " ", @_ if $1 eq "dependency";
    $output .= "perl -pi -e \"s,^prefix=.*\$\$,prefix=TARGET/usr,\" " . join " ", @_ if $1 eq "pkgconfig";
  }
  else
  {
    die "can't recognize rule \"$rule\"";
  }

  return $output;
}

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

sub process_install ($$)
{
  my @rules = @{$_[1]};
  my $output = "";
  $version = shift @rules;
  shift @rules;

  foreach ( @rules )
  {
    $output .= " && " if $output;
    $output .= process_install_rule ($_);
  }

  return $output;
}

sub process_uninstall ($$)
{
  my @rules = @{$_[1]};
  my $output = "";
  shift @rules;
  shift @rules;

  foreach ( @rules )
  {
    $output .= " && " if $output;
    $output .= process_uninstall_rule ($_);
  }

  return $output;
}

sub process_make_sources ($$$)
{
  shift;
  shift;
  my $output = "";
  
  foreach ( @_ )
  {
    my ($p, $f, $cmd) = process_rule($_);
    next if ( $p eq "none" );
    $_ =~ s/$cmd:// if ($cmd ne "");
    $output .= $_ . " ";
  }
  return "\"$output\""
}

sub process_download ($$)
{
  my @rules = @{$_[1]};
  process_make_version (@rules);

  my $head;
  my $output = "";

  shift @rules;
  shift @rules;
  foreach ( @rules )
  {
    my ($p, $f, $cmd, $url, %opts) = process_rule($_);
    next if ( $p eq "file" || $p eq "none" );
    
    $_ =~ s/$cmd:// if ($cmd ne "");

    if( subs_vars($_) ~~ @allurls )
    {
       print $_ . "\n";
       next;
    }
    push(@allurls, $_); 
    
    #warn "download: " . $url . "\n";
    
    $head .= " \$(archivedir)/" . $f;
    $output .= " \$(archivedir)/" . $f . ":\n\tfalse";

    if ( $_ =~ m#^ftp://# )
    {
      $output .= " || \\\n\twget -c --passive-ftp -P \$(archivedir) " . $_;
    }
    elsif ( $_ =~ m#^http://# )
    {
      $output .= " || \\\n\twget -c -P \$(archivedir) " . $_;
    }
#     elsif ( $_ =~ m#^CMD_CVS # )
#     {
#       $output .= " || \\\n\tcd \$(archivedir) && " . $_;
#       my $cvsstring = $_;
#       $cvsstring =~ s/ co / up /;
#       $outputupdate .= "\$(archivedir)" . $file . "up:\n\tfalse";
#       $outputupdate .= " || \\\n\tcd \$(archivedir) && " . $cvsstring;
#     }
    elsif ( $_ =~ m#^svn://# )
    {
      $output .= " || \\\n\tsvn checkout $url" . " \$(archivedir)/" . $f;
      $output .= " -r " . $opts{"r"} if $opts{"r"};
    }
    elsif ( $url =~ m#^git://# )
    {
      $output .= " || \\\n\tgit clone $url" . " \$(archivedir)/" . $f;
      $output .= " -b " . $opts{"b"} if $opts{"b"};
      $output .= " && (cd \$(archivedir)/" . $f . "; git checkout " . $opts{"r"} . "; cd -) " if $opts{"r"};
    }

    elsif ( $f =~ m/gz$/ )
    {
      $output .= " || \\\n\twget -c -P \$(archivedir) ftp://ftp.stlinux.com/pub/stlinux/2.0/ST_Linux_2.0/RPM_Distribution/sh4-target-glibc-packages/" . $f;
      $output .= "\n\t\@touch \$\@";
    }
  #   elsif ( $file =~ m/cvs$/ )
  #   {
  #     $output .= " || \\\n\twget -c ftp://xxx.com/pub/tufsbox/cdk/src/" . $file;
  #     $filerep =~ s/\.cvs//;
  #     $output .= "\n\t\@touch -r \$(archivedir) " . $filerep . "/CVS \$\@";
  #     $outputupdate .= "\n\t\@touch -r \$(archivedir) " . $filerep . "/CVS \$\(subst cvsup,cvs,\$\@\)";
  #     $outputupdate .= "\n\n";
  #   }
    else
    {
      $output .= " || \\\n\twget -c -P \$(archivedir) http://tuxbox.berlios.de/pub/tuxbox/cdk/src/" . $f;
      $output .= "\n\t\@touch \$\@";
    }
    $output .= "\n\n";
  }
  return "$output"

}

# $output =~ s#CMD_CVS#\$\(CMD_CVS\)#g;
# $outputupdate =~ s#CMD_CVS#\$\(CMD_CVS\)#g;
# 
# print $head . "\n\n" . $output . "\n\n" . $outputupdate . "\n";

#TODO:
#die "please specify a filename and at least one package" if $#ARGV < 2;


sub subs_vars($)
{
  my $output = shift;
  $output =~ s#TARGETNAME#\$\(target\)#g;
  $output =~ s#TARGETS#\$\(prefix\)\/\$\*cdkroot#g;
  $output =~ s#TARGET#\$\(targetprefix\)#g;
  $output =~ s#HCTDINST#HHL\_CROSS\_TARGET\_DIR\=\$\(prefix\)\/\$\*cdkroot#g;
  $output =~ s#HCTDUNINST#HHL\_CROSS\_TARGET\_DIR\=\$\(targetprefix\)#g;
  $output =~ s#HOST#\$\(hostprefix\)#g;
  $output =~ s#BUILD#\$\(buildprefix\)#g;
  $output =~ s#PKDIR#\$\(packagingtmpdir\)#g;
  $output =~ s#\{PV\}#$version#g;
  my $dashpackage = $package;
  $dashpackage =~ s#_#\-#g;
  $output =~ s#\{PN\}#$dashpackage#g;
  return $output
}

load ( $filename, 0 );

#print subs_vars($allout) . "\n";
