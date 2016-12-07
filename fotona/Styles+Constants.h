//
//  Styles+Constants.h
//  fotona
//
//  Created by Janos on 29/07/15.
//  Copyright (c) 2015 4egenus. All rights reserved.
//

#ifndef fotona_Styles_Constants_h
#define fotona_Styles_Constants_h

//bookmark types
#define BOOKMARKIMAGE @"0"
#define BOOKMARKVIDEO @"1"
#define BOOKMARKPDF @"2"
#define BOOKMARKNEWS @"3"
#define BOOKMARKEVENTS @"4"
#define BOOKMARKCASE @"5"

#define BOOKMARKIMAGEINT 0
#define BOOKMARKVIDEOINT 1
#define BOOKMARKPDFINT 2
#define BOOKMARKNEWSINT 3
#define BOOKMARKEVENTSINT 4
#define BOOKMARKCASEINT 5

//bookmark source type
#define BSOURCECASE 0
#define BSOURCEFOTONA 1
#define BSOURCEALL 2


//MEDIA TYPE
#define MEDIAIMAGE @"0"
#define MEDIAVIDEO @"1"
#define MEDIAPDF @"2"

//GA TYPES
#define GACASEINT 0
#define GACASEMENUINT 1
#define GAFOTONAWEBPAGEINT 2
#define GAFOTONAPDFINT 3
#define GAFOTONAVIDEOINT 4
#define GAFEATUREDTABINT 5
#define GAEVENTTABINT 6
#define GAFAVORITETABINT 7

//COLORS
#define DISABLEDCOLORALPHA 0.4

#define FOTONARED @"ED1C24"

//FOTONA CATEGORY TYPES
#define CATEGORYPDF @"6"
#define CATEGORVIDEO @"4"

//FOLDERS
#define FOLDERPDF @".PDF"
#define FOLDERIMAGE @".Cases"
#define FOLDERVIDEO @".Cases"


//LINKS
#define FOTONAWEBSERVICE @"https://www.fotona.com/inc/verzija2/ajax/" // link to news in events

#define WEBSERVICEPLUTON @"https://plutontest.4egenus.com/fot-dev/fotApi/api/"//pluton test new
#define WEBSERVICEPROD @"https://fotonaapp.4egenus.com/rest/WebService.asmx/api/"//production
#define WEBSERVICEPROD2 @"https://fotonaapp2.4egenus.com/fotapi/api"//production2

#define WEBSERVICE [NSString stringWithFormat:@"%@",WEBSERVICEPROD2]

#define LINKDISCLAIMER @"/FotDisclaimer/Get"
#define LINKCASECATEGORY @"/FotCaseCategories/GetAllCaseCategories"
#define LINKCASES @"/FotCases/GetAllCases"
#define LINKCASEBYID @"/FotCases/GetCaseByID"
#define LINKAUTHORS @"/FotAuthors/GetAllAuthors"
#define LINKDOCUMENTS @"/FotDocuments/GetAllDocuments"
#define LINKFOTONATAB @"/FotFotonaContent/GetFotonaTab"
#define LINKWRITEDEVICE @"/FotDevices/WriteDevice"

//NOTIFICATION TYPE

#define NOTIFICATIONMEDIA 1
#define NOTIFICATIONCASE 2


//FOTONA CATEGORY TYPE

#define FOTONACATEGORYMENU @"1"
#define FOTONACATEGORYWEBPAGE @"2"
#define FOTONACATEGORYCASE @"3"
#define FOTONACATEGORYVIDEO @"4"
#define FOTONACATEGORYCONTENT @"5"
#define FOTONACATEGORYPDF @"6"
#define FOTONACATEGORYPRELODED @"7"

//DB COLUMN NAMES

#define USERPERMISSIONCOLUMNNAME @"userPermissions"


#endif
