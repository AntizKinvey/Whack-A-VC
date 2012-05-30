//
//  DBManager.h
//  WhackAVC
//
//  
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DBManager : NSObject
{
    sqlite3 *db;
    NSMutableArray *_retrieveArray;
    NSMutableArray *_retrieveImageIdArray;
    NSMutableArray *_retrieveImageFirmArray;
    NSMutableArray *_retrieveVCNameArray;
    NSMutableArray *_whackedAudioPaths;
    NSMutableArray *_vcFirmArrayFromDB;
    NSMutableArray *_vcSnapsArrayFromDB;
    NSMutableArray *_vcNamesArrayFromDB;
    NSMutableArray *_vcTwitterHandleArrayFromDB;
    
    NSMutableArray *_myVCSnapsFromDB;
    NSMutableArray *_myVCFirmsFromDB;
    NSMutableArray *_myVCWhackCountFromDB;
    NSMutableArray *_myVCNamesFromDB;
    NSMutableArray *_myVCTwitterHandleFromDB;
    
    NSMutableArray *_allVCSnapsFromDB;
    NSMutableArray *_allVCFirmsFromDB;
    NSMutableArray *_allVCWhackCountFromDB;
    NSMutableArray *_allVCNamesFromDB;
    NSMutableArray *_allVCTwitterHandleFromDB;
    
    NSMutableArray *_resourcesInDB;
    NSMutableArray *_resourcesLastModifiedInDB;
    
    NSMutableArray *_vcIdFromVClistArray;
    NSMutableArray *_vcKinveyIdFromVClistArray;
    NSMutableArray *_vcIdFromWhacklistArray;
    
    NSMutableArray *_vcKinveyIdFromWhacklistArray;
    NSMutableArray *_vcWhackCountFromWhacklistArray;
    
    NSMutableArray *_vcIdsFromTemp;
    NSMutableArray *_vcNamesFromTemp;
    NSMutableArray *_vcFirmsFromTemp;
    NSMutableArray *_vcWhacksFromTemp;
    NSMutableArray *_vcSnapsFromTemp;
    NSMutableArray *_vcTwHandlesFromTemp;
    
    NSString *_topPhrase;
}

@property (retain) NSMutableArray *_retrieveArray;
@property (retain) NSMutableArray *_retrieveImageIdArray;
@property (retain) NSMutableArray *_retrieveImageFirmArray;
@property (retain) NSMutableArray *_retrieveVCNameArray;
@property (retain) NSMutableArray *_whackedAudioPaths;
@property (retain) NSMutableArray *_vcFirmArrayFromDB;
@property (retain) NSMutableArray *_vcSnapsArrayFromDB;
@property (retain) NSMutableArray *_vcNamesArrayFromDB;
@property (retain) NSMutableArray *_vcTwitterHandleArrayFromDB;
@property (retain) NSMutableArray *_myVCSnapsFromDB;
@property (retain) NSMutableArray *_myVCFirmsFromDB;
@property (retain) NSMutableArray *_myVCWhackCountFromDB;
@property (retain) NSMutableArray *_myVCNamesFromDB;
@property (retain) NSMutableArray *_myVCTwitterHandleFromDB;
@property (retain) NSMutableArray *_allVCSnapsFromDB;
@property (retain) NSMutableArray *_allVCFirmsFromDB;
@property (retain) NSMutableArray *_allVCWhackCountFromDB;
@property (retain) NSMutableArray *_allVCNamesFromDB;
@property (retain) NSMutableArray *_allVCTwitterHandleFromDB;

@property (retain) NSMutableArray *_resourcesInDB;
@property (retain) NSMutableArray *_resourcesLastModifiedInDB;

@property (retain) NSMutableArray *_vcIdFromVClistArray;
@property (retain) NSMutableArray *_vcKinveyIdFromVClistArray;
@property (retain) NSMutableArray *_vcIdFromWhacklistArray;

@property (retain) NSMutableArray *_vcKinveyIdFromWhacklistArray;
@property (retain) NSMutableArray *_vcWhackCountFromWhacklistArray;


@property (retain) NSMutableArray *_vcIdsFromTemp;
@property (retain) NSMutableArray *_vcNamesFromTemp;
@property (retain) NSMutableArray *_vcFirmsFromTemp;
@property (retain) NSMutableArray *_vcWhacksFromTemp;
@property (retain) NSMutableArray *_vcSnapsFromTemp;
@property (retain) NSMutableArray *_vcTwHandlesFromTemp;

@property (retain) NSString *_topPhrase;

//To check filePath
-(NSString *)filePath;
//---create database---
-(void) openDB;

//Table for VCList
-(void) createTableVC:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5 withField6:(NSString *) field6 withField7:(NSString *) field7;

//Table for Temp
-(void) createTableTemp:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5 withField6:(NSString *) field6;

//Table for MetaData
-(void) createTableMetaData:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3;

//Table for Audio
-(void) createTableAudio:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2;

//Table for Phraselist
-(void) createTablePhrase:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2;

//Table for User
-(void) createTableUser:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2;

//Table for Whacklist
-(void) createTableWhacks:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5;

//Save VC game play Images in documents directory
-(id) saveImagesToDocumentsDirectory:(NSInteger) imageNumber;

//Save VC profile Images in documents directory
-(id) saveSnapImagesToDocumentsDirectory:(NSInteger) snapImageNumber;

//Save Audio files to documents directory
-(id) saveAudioFilesToDirectory:(NSInteger) audioNumber;

//Insert Values to MetaData Table
-(void) insertRecordIntoMetaDataTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value;

//Insert Values to VClist Table
-(void) insertRecordIntoVClistTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value andField6: (NSString *) field6 field6Value: (NSString *) field6Value andField7: (NSString *) field7 field7Value: (NSString *) field7Value;

//Insert Values to Temp Table
-(void) insertRecordIntoTempTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value andField6: (NSString *) field6 field6Value: (NSString *) field6Value;

//Insert Values to Phraselist Table
-(void) insertRecordIntoPhraseTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value;

//Insert Values to Audiolist Table
-(void) insertRecordIntoAudioTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value;

//Insert Values to User Table
-(void) insertRecordIntoUserTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value;

//Insert Values to Whacklist Table
-(void) insertRecordIntoWhacklistTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value;

//Update records to User table
-(void) updateRecordIntoUserTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value;

//Update records to Whacklist table
-(void) updateRecordIntoWhacklistTable:(NSString *)usql;

//Update records to MetaData table
-(void) updateRecordIntoMetaDataTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value;

//Retrieve number of rows in User table
-(int) retrieveNoOfRowsInUser:(NSString *)qsql;

//Retrieve Scores from User table
-(int) retrieveScoreOfUser:(NSString *)qsql;

//Retrieve VC game image paths from VClist table
-(int) retrieveVCImagesPaths;

//Retrieve VC shouts from Audiolist table
-(int) retrieveVCWhackAudioPaths;

//Retrieve VC firm names and VC names from VClist table
-(void) retrieveVCFirmsAndNames:(NSString *)qsql;

//Retrieve VC profile images and VC game play images from VClist table
-(int) retrieveVCSnapPathsAndFirms:(NSString *)qsql;

//Check number of rows in VClist table
-(int) checkNumberOfRowsInVClistTable:(NSString *)qsql;

//Check number of rows in Whacklist table
-(int) checkNumberOfRowsInWhacklistTable:(NSString *)qsql;

//Retrieve records from Whacklist table for whack count for each VC
-(int) retrieveRecordsForWhackCount:(NSString *)wsql;

//Retrieve records from Whacklist table for My VC's
-(int) retrieveRecordsFromWhacklistTableForMyVCs:(NSString *)rsql;

//Retrieve records from Whacklist table for All VC's
-(int) retrieveRecordsFromWhacklistTableForAllVCs:(NSString *)rsql;

//Retrieve random phrase text from Phraselist table
-(void) retrieveRandomPhrasesFromDB:(NSString *)qsql;

//Retrieve number of records from MetaData table
-(int) retrieveNumberOfRecordsFromMetaData:(NSString *)rsql;

//Retrieve records from MetaData table
-(void) retrieveRecordsFromMetaData;

//Retrieve VC ID's from VClist table
-(void) retrieveVCIDsFromVClist;

//Retrieve VC ID's from Whacklist table
-(void) retrieveVCIDsFromWhacklist;

//Retrieve records from Whacklist table to save to Kinvey
-(void) retrieveRecordsFromWhacklistToSave;

//Retrieve records from Temp table
-(void) retrieveRecordsFromTemp;

//Delete records frpm Temp table
-(void) deleteRecordsFromTemp;

//Close database
-(void) closeDB;

@end
