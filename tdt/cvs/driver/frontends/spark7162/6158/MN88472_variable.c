

#include "nim_panic6158.h"

UINT32	logtbl[] = {
0	,-1000,-699	,-523,-398,
-301,-222 ,-155	,-97 ,-46 ,
0	,41	,79	,114	,146	,
176	,204	,230	,255	,
279	,301	,322	,342	,
362	,380	,398	,415	,
431	,447	,462	,477	,
491	,505	,519	,531	,
544	,556	,568	,580	,
591	,602	,613	,623	,
633	,643	,653	,663	,
672	,681	,690	,699	,
708	,716	,724	,732	,
740	,748	,756	,763	,
771	,778	,785	,792	,
799	,806	,813	,820	,
826	,833	,839	,845	,
851	,857	,863	,869	,
875	,881	,886	,892	,
898	,903	,908	,914	,
919	,924	,929	,934	,
940	,944	,949	,954	,
959	,964	,968	,973	,
978	,982	,987	,991	,
996

/* '11/10/24 : OKAMOTO	Update to "MN88472_Device_Driver_111012" */
,1000
};

UINT32 DMD_DVBT_CNR_P1[3][5] =
{	{ 510 ,	 690 ,  790 , 890 , 970 } ,
	{1080 ,	1310 , 1460 ,1560 , 1600} ,
    {1650 , 1870 , 2020 ,2160 , 2250 }
};
UINT32 DMD_DVBT2_CNR_P1[4][6] =
{	{ 350 ,	 470 ,  560 , 660 , 720 , 770 } ,
	{ 870 ,	1010 , 1140 ,1250 , 1330, 1380} ,
    {1300 , 1480 , 1620 ,1770 , 1870, 1940} ,
	{1700 , 1940 , 2080 ,2290 , 2430, 2510}
};
