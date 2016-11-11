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

#define WEBSERVICEPLUTON @"https://plutontest.4egenus.com/fot-dev/fotApi"//pluton test new
#define WEBSERVICEPROD @"https://fotonaapp.4egenus.com/rest/WebService.asmx/"//production
#define WEBSERVICE [NSString stringWithFormat:@"%@",WEBSERVICEPLUTON]

#define LINKDISCLAIMER @"/api/FotDisclaimer/Get"
#define LINKCASECATEGORY @"/api/FotCaseCategories/GetAllCaseCategories"
#define LINKCASES @"/api/FotCases/GetAllCases"
#define LINKCASEBYID @"/api/FotCases/GetCaseByID"
#define LINKAUTHORS @"/api/FotAuthors/GetAllAuthors"
#define LINKDOCUMENTS @"/api/FotDocuments/GetAllDocuments"
#define LINKFOTONATAB @"/api/FotFotonaContent/GetFotonaTab"
#define LINKWRITEDEVICE @"/api/FotDevices/WriteDevice"

#endif
