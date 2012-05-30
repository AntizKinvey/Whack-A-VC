//
//  DBManager.m
//  WhackAVC
//
//  Created by Antiz Technologies on 3/15/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

@synthesize _retrieveArray;
@synthesize _retrieveImageIdArray;
@synthesize _retrieveImageFirmArray;
@synthesize _retrieveVCNameArray;
@synthesize _whackedAudioPaths;
@synthesize _vcFirmArrayFromDB;
@synthesize _vcSnapsArrayFromDB;
@synthesize _vcNamesArrayFromDB;
@synthesize _vcTwitterHandleArrayFromDB;
@synthesize _myVCSnapsFromDB;
@synthesize _myVCFirmsFromDB;
@synthesize _myVCWhackCountFromDB;
@synthesize _myVCNamesFromDB;
@synthesize _myVCTwitterHandleFromDB;
@synthesize _allVCSnapsFromDB;
@synthesize _allVCFirmsFromDB;
@synthesize _allVCWhackCountFromDB;
@synthesize _allVCNamesFromDB;
@synthesize _allVCTwitterHandleFromDB;

@synthesize _resourcesInDB;
@synthesize _resourcesLastModifiedInDB;

@synthesize _vcIdFromVClistArray;
@synthesize _vcKinveyIdFromVClistArray;
@synthesize _vcIdFromWhacklistArray;

@synthesize _vcKinveyIdFromWhacklistArray;
@synthesize _vcWhackCountFromWhacklistArray;

@synthesize _vcIdsFromTemp;
@synthesize _vcNamesFromTemp;
@synthesize _vcFirmsFromTemp;
@synthesize _vcWhacksFromTemp;
@synthesize _vcSnapsFromTemp;
@synthesize _vcTwHandlesFromTemp;

@synthesize _topPhrase;

int no_Of_Rows_In_User_Table = 0;


///To check filePath
-(NSString *) filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"whackavcdb.sqlite"];
}

-(void) openDB {
    //---create database---
    if (sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK ) {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to open."); 
    }
    
}

//Table for MetaData
-(void) createTableMetaData:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3
{
    char *err;
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT, '%@' TEXT);", tableName, field1, field2, field3];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table VCList failed to create.");
    }
}

//Table for VCList
-(void) createTableVC:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5 withField6:(NSString *) field6 withField7:(NSString *) field7
{
    char *err;
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT);", tableName, field1, field2, field3, field4, field5, field6, field7];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table VCList failed to create.");
    }
}

//Table for TempList
-(void) createTableTemp:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5 withField6:(NSString *) field6
{
    char *err;
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT , '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT);", tableName, field1, field2, field3, field4, field5, field6];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table VCList failed to create.");
    }
}

//Table for AudioList
-(void) createTableAudio:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT);", tableName, field1, field2];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table Audio failed to create.");
    }
}

//Table for PhraseList
-(void) createTablePhrase:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT);", tableName, field1, field2];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table Phrase failed to create.");
    }
    
}


//Table for User
-(void) createTableUser:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT);", tableName, field1, field2];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table User failed to create.");
    }
    
}

//Table for Whacklist
-(void) createTableWhacks:(NSString *) tableName withField1:(NSString *) field1 withField2:(NSString *) field2 withField3:(NSString *) field3 withField4:(NSString *) field4 withField5:(NSString *) field5
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT);", tableName, field1, field2, field3, field4, field5];
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    { 
        sqlite3_close(db);
        NSAssert(0, @"Table Whacks failed to create.");
    }
    
}


//Save VC game play Images in documents directory
-(id) saveImagesToDocumentsDirectory:(NSInteger) imageNumber
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"vc%d.png",imageNumber]];
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"vc%d.png",imageNumber]];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:savedImagePath atomically:NO];
    
    
    return savedImagePath;
}

//Save VC profile Images in documents directory
-(id) saveSnapImagesToDocumentsDirectory:(NSInteger) snapImageNumber
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedSnapImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"vcsnap%d.png",snapImageNumber]];
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"vcsnap%d.png",snapImageNumber]];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:savedSnapImagePath atomically:NO];
    
    
    return savedSnapImagePath;
}

//Save Audio files to documents directory
-(id) saveAudioFilesToDirectory:(NSInteger) audioNumber
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedAudioPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sound%d.wav",audioNumber]];
    
    
    NSString *localaudioPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"sound%d",audioNumber] ofType:@"wav"];
    NSData *audioData = [NSData dataWithContentsOfFile:localaudioPath];
    [audioData writeToFile:savedAudioPath atomically:NO];
    
    return savedAudioPath; 
}


//Insert Values to MetaData Table
-(void) insertRecordIntoMetaDataTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@') VALUES ('%@','%@', '%@')", tableName, field1, field2, field3, field1Value, field2Value, field3Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table VCList."); 
    } 
}

//Insert records to VClist table
-(void) insertRecordIntoVClistTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value andField6: (NSString *) field6 field6Value: (NSString *) field6Value andField7: (NSString *) field7 field7Value: (NSString *) field7Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@')", tableName, field1, field2, field3, field4, field5, field6, field7, field1Value, field2Value, field3Value, field4Value, field5Value, field6Value, field7Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table VCList."); 
    } 
}

//Insert records to Temp table
-(void) insertRecordIntoTempTable: (NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value andField6: (NSString *) field6 field6Value: (NSString *) field6Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@','%@', '%@', '%@', '%@', '%@')", tableName, field1, field2, field3, field4, field5, field6, field1Value, field2Value, field3Value, field4Value, field5Value, field6Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table VCList."); 
    } 
}

//Insert records to Whacklist table
-(void) insertRecordIntoWhacklistTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value andField3: (NSString *) field3 field3Value: (NSString *) field3Value andField4: (NSString *) field4 field4Value: (NSString *) field4Value andField5: (NSString *) field5 field5Value: (NSString *) field5Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES ('%@','%@','%@','%@', '%@')", tableName, field1, field2, field3, field4, field5, field1Value, field2Value, field3Value, field4Value, field5Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error Inserting Whacklist table."); 
    } 
}

//Insert records to Phraselist table
-(void) insertRecordIntoPhraseTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES ('%@','%@')", tableName, field1, field2, field1Value, field2Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table."); 
    } 
}

//Insert records to Audiolist table
-(void) insertRecordIntoAudioTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES ('%@','%@')", tableName, field1, field2, field1Value, field2Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table."); 
    } 
}

//Insert records to User table
-(void) insertRecordIntoUserTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value
{
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES ('%@','%@')", tableName, field1, field2, field1Value, field2Value];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table."); 
    } 
}

//Update records to User table
-(void) updateRecordIntoUserTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value
{
    
    NSString *ssql = [NSString stringWithFormat:@"UPDATE User SET score = '%@' WHERE usrid = '1'",field2Value];
    char *err;
    if (sqlite3_exec(db, [ssql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table."); 
    } 
}

//Update records to Whacklist table
-(void) updateRecordIntoWhacklistTable:(NSString *)usql
{
    char *err;
    if (sqlite3_exec(db, [usql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error Updating Whacklist table."); 
    }
}

//Update records to MetaData table
-(void) updateRecordIntoMetaDataTable:(NSString *) tableName withField1: (NSString *) field1 field1Value: (NSString *) field1Value andField2: (NSString *) field2 field2Value: (NSString *) field2Value
{
    NSString *ssql = [NSString stringWithFormat:@"UPDATE MetaData SET lastModifiedTime = '%@' WHERE resourceName = '%@'",field1Value,field2Value];
    char *err;
    if (sqlite3_exec(db, [ssql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table."); 
    } 
}

//Retrieve number of rows in User table
-(int) retrieveNoOfRowsInUser:(NSString *)qsql
{
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            
            NSString *str = [[NSString alloc] initWithFormat:@"%@", field1Str];
            
            [field1Str release];
            [str release];
            
            no_Of_Rows_In_User_Table = 1;
        }
        else
        {
            no_Of_Rows_In_User_Table = 0;
        }
        sqlite3_finalize(statement);
    }
    return no_Of_Rows_In_User_Table;
}

//Retrieve Scores from User table
-(int) retrieveScoreOfUser:(NSString *)qsql
{
    sqlite3_stmt *statement;
    
    NSString *sql1 = @"SELECT score FROM User";
    const char *s = [sql1 UTF8String];
    int scorefromdb = 0;
    if(sqlite3_prepare_v2(db,s,-1,&statement,nil) == SQLITE_OK)
    { 
        printf("\n\nDB MANAGER1");
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            
            printf("\n\nINSIDE WHILE LOOP");
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            scorefromdb = [str intValue];
            
            [field1Str release];
            [str release];
            
        }
        
        sqlite3_finalize(statement);
        
    }
    
    return scorefromdb;
}

//Retrieve VC game image paths from VClist table
-(int) retrieveVCImagesPaths
{
    NSString *qsql = @"SELECT vcphoto,vcid FROM VClist";
    sqlite3_stmt *statement; 
    
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_retrieveArray addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_retrieveImageIdArray addObject:str2];
            
            [field1Str release];
            [field2Str release];
            [str1 release];
            [str2 release];
        }
        
        sqlite3_finalize(statement);
    }
    return [_retrieveArray count];
}

//Retrieve VC firm names and VC names from VClist table
-(void) retrieveVCFirmsAndNames:(NSString *)qsql
{
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_retrieveImageFirmArray addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_retrieveVCNameArray addObject:str2];
            
            
            [field1Str release];
            [field2Str release];
            [str1 release];
            [str2 release];
            
        }
        
        sqlite3_finalize(statement);
        
    }
    
}

//Retrieve VC shouts from Audiolist table
-(int) retrieveVCWhackAudioPaths
{
    NSString *qsql = @"SELECT audioname FROM Audiolist";
    sqlite3_stmt *statement; 
    
//    _whackedAudioPaths = [[NSMutableArray alloc] init];
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *audiostr = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_whackedAudioPaths addObject:audiostr];
            
            [field1Str release];
            [audiostr release];
        }
        sqlite3_finalize(statement);
    }
    return [_whackedAudioPaths count];
}

//Retrieve VC profile images and VC game play images from VClist table
-(int) retrieveVCSnapPathsAndFirms:(NSString *)qsql
{
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_vcFirmArrayFromDB addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_vcSnapsArrayFromDB addObject:str2];
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String:field3];
            NSString *str3 = [[NSString alloc] initWithFormat:@"%@",field3Str];
            [_vcNamesArrayFromDB addObject:str3];
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String:field4];
            NSString *str4 = [[NSString alloc] initWithFormat:@"%@",field4Str];
            [_vcTwitterHandleArrayFromDB addObject:str4];
            
            [field1Str release];
            [field2Str release];
            [field3Str release];
            [field4Str release];
            [str1 release];
            [str2 release];
            [str3 release];
            [str4 release];
        }
        sqlite3_finalize(statement);
    }
    return 1;
}

//Retrieve random phrase text from Phraselist table
-(void) retrieveRandomPhrasesFromDB:(NSString *)qsql
{
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            _topPhrase = [NSString stringWithString:str];
            
            [field1Str release];
            [str release];
        }
        sqlite3_finalize(statement);
    }
}

//Check number of rows in VClist table
-(int) checkNumberOfRowsInVClistTable:(NSString *)qsql
{
    sqlite3_stmt *statement; 
    int _noOfRowsInVClistTable = 0;
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            
            _noOfRowsInVClistTable = [str1 intValue];
            
            [field1Str release];
            [str1 release];
        }
        sqlite3_finalize(statement);
    }
    return _noOfRowsInVClistTable;
}

//Check number of rows in Whacklist table
-(int) checkNumberOfRowsInWhacklistTable:(NSString *)qsql
{
    sqlite3_stmt *statement; 
    int _noOfRowsInWhacklistTable = 0;
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            _noOfRowsInWhacklistTable = 1;
        }
        else
        {
            _noOfRowsInWhacklistTable = 0;
        }
        sqlite3_finalize(statement);
    }
    return _noOfRowsInWhacklistTable;
}

//Retrieve records from Whacklist table for My VC's
-(int) retrieveRecordsFromWhacklistTableForMyVCs:(NSString *)rsql
{
    sqlite3_stmt *statement;
    int _noOfRowsForMyVCs = 0;
    
    if(sqlite3_prepare_v2(db,[rsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_myVCSnapsFromDB addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_myVCFirmsFromDB addObject:str2];
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String:field3];
            NSString *str3 = [[NSString alloc] initWithFormat:@"%@",field3Str];
            [_myVCWhackCountFromDB addObject:str3];
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String:field4];
            NSString *str4 = [[NSString alloc] initWithFormat:@"%@",field4Str];
            [_myVCNamesFromDB addObject:str4];
            
            char *field5 = (char *) sqlite3_column_text(statement,4);
            NSString *field5Str = [[NSString alloc] initWithUTF8String:field5];
            NSString *str5 = [[NSString alloc] initWithFormat:@"%@",field5Str];
            [_myVCTwitterHandleFromDB addObject:str5];
            
            _noOfRowsForMyVCs++;
            
            [field1Str release];
            [str1 release];
            [field2Str release];
            [str2 release];
            [field3Str release];
            [str3 release];
            [field4Str release];
            [str4 release];
            [field5Str release];
            [str5 release];
        }
        sqlite3_finalize(statement);
    }
    return _noOfRowsForMyVCs;
}

//Retrieve records from Whacklist table for All VC's
-(int) retrieveRecordsFromWhacklistTableForAllVCs:(NSString *)rsql
{
    sqlite3_stmt *statement;
    int _noOfRowsForAllVCs = 0;
    
    if(sqlite3_prepare_v2(db,[rsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_allVCSnapsFromDB addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_allVCFirmsFromDB addObject:str2];
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String:field3];
            NSString *str3 = [[NSString alloc] initWithFormat:@"%@",field3Str];
            [_allVCWhackCountFromDB addObject:str3];
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String:field4];
            NSString *str4 = [[NSString alloc] initWithFormat:@"%@",field4Str];
            [_allVCNamesFromDB addObject:str4];
            
            char *field5 = (char *) sqlite3_column_text(statement,4);
            NSString *field5Str = [[NSString alloc] initWithUTF8String:field5];
            NSString *str5 = [[NSString alloc] initWithFormat:@"%@",field5Str];
            [_allVCTwitterHandleFromDB addObject:str5];
            
            _noOfRowsForAllVCs++;
            
            [field1Str release];
            [str1 release];
            [field2Str release];
            [str2 release];
            [field3Str release];
            [str3 release];
            [field4Str release];
            [str4 release];
            [field5Str release];
            [str5 release];
        }
        sqlite3_finalize(statement);
    }
    return _noOfRowsForAllVCs;
}

//Retrieve records from Whacklist table for whack count for each VC
-(int) retrieveRecordsForWhackCount:(NSString *)wsql
{
    sqlite3_stmt *statement;
    int _whackScore = 0;
    
    if(sqlite3_prepare_v2(db,[wsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            _whackScore = [str intValue];
            
            
            [field1Str release];
            [str release];
        }
        sqlite3_finalize(statement);
    }
    return _whackScore;
}

//Retrieve number of records from MetaData table
-(int) retrieveNumberOfRecordsFromMetaData:(NSString *)rsql
{
    sqlite3_stmt *statement;
    int _noOfRowsInMetaData = 0;
    if(sqlite3_prepare_v2(db,[rsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            
            _noOfRowsInMetaData = [str1 intValue];
            
            [field1Str release];
            [str1 release];
        }
        sqlite3_finalize(statement);
    }
    return _noOfRowsInMetaData;
}

//Retrieve records from MetaData table
-(void) retrieveRecordsFromMetaData
{
    sqlite3_stmt *statement;
    NSString *rsql = @"SELECT resourceName,lastModifiedTime FROM MetaData";
    if(sqlite3_prepare_v2(db,[rsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];
            [_resourcesInDB addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            [_resourcesLastModifiedInDB addObject:str2];
            
            [field1Str release];
            [str1 release];
            [field2Str release];
            [str2 release];
        }
        sqlite3_finalize(statement);
    }
}

//Retrieve VC ID's from VClist table
-(void) retrieveVCIDsFromVClist
{
    NSString *qsql = @"SELECT vcid,vcKinveyId FROM VClist";
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            [_vcIdFromVClistArray addObject:str];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            
            [_vcKinveyIdFromVClistArray addObject:str1];
            
            [field1Str release];
            [field2Str release];
            [str release];
            [str1 release];
        }
        sqlite3_finalize(statement);
    }
}

//Retrieve VC ID's from Whacklist table
-(void) retrieveVCIDsFromWhacklist
{
    NSString *qsql = @"SELECT vcid FROM Whacklist";
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            [_vcIdFromWhacklistArray addObject:str];
            
            [field1Str release];
            [str release];
        }
        sqlite3_finalize(statement);
    }
}

//Retrieve records from Whacklist table to save to Kinvey
-(void) retrieveRecordsFromWhacklistToSave
{
    NSString *qsql = @"SELECT w.vcKinveyId,w.whackcount FROM Whacklist w  WHERE w.whackcount > 0";
     
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str = [[NSString alloc] initWithFormat:@"%@",field1Str];
            
            [_vcKinveyIdFromWhacklistArray addObject:str];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            
            [_vcWhackCountFromWhacklistArray addObject:str1];
            
            [field1Str release];
            [field2Str release];
            [str release];
            [str1 release];
        }
        sqlite3_finalize(statement);
    }
}

//Retrieve records from Temp table
-(void) retrieveRecordsFromTemp
{
    NSString *qsql = @"SELECT * FROM Temp ORDER BY vcname";
    sqlite3_stmt *statement; 
    
    if(sqlite3_prepare_v2(db,[qsql UTF8String],-1,&statement,nil) == SQLITE_OK)
    { 
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement,0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
            NSString *str1 = [[NSString alloc] initWithFormat:@"%@",field1Str];

            [_vcIdsFromTemp addObject:str1];
            
            char *field2 = (char *) sqlite3_column_text(statement,1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String:field2];
            NSString *str2 = [[NSString alloc] initWithFormat:@"%@",field2Str];
            
            [_vcNamesFromTemp addObject:str2];
            
            char *field3 = (char *) sqlite3_column_text(statement,2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String:field3];
            NSString *str3 = [[NSString alloc] initWithFormat:@"%@",field3Str];
            
            [_vcFirmsFromTemp addObject:str3];
            
            char *field4 = (char *) sqlite3_column_text(statement,3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String:field4];
            NSString *str4 = [[NSString alloc] initWithFormat:@"%@",field4Str];
            
            [_vcSnapsFromTemp addObject:str4];
            
            char *field5 = (char *) sqlite3_column_text(statement,4);
            NSString *field5Str = [[NSString alloc] initWithUTF8String:field5];
            NSString *str5 = [[NSString alloc] initWithFormat:@"%@",field5Str];
            
            [_vcTwHandlesFromTemp addObject:str5];
            
            char *field6 = (char *) sqlite3_column_text(statement,5);
            NSString *field6Str = [[NSString alloc] initWithUTF8String:field6];
            NSString *str6 = [[NSString alloc] initWithFormat:@"%@",field6Str];
            
            [_vcWhacksFromTemp addObject:str6];
            
            [field1Str release];
            [field2Str release];
            [field3Str release];
            [field4Str release];
            [field5Str release];
            [field6Str release];
            [str1 release];
            [str2 release];
            [str3 release];
            [str4 release];
            [str5 release];
            [str6 release];
        }
        sqlite3_finalize(statement);
    }
}

//Delete records frpm Temp table
-(void) deleteRecordsFromTemp
{
    NSString *ssql = [NSString stringWithFormat:@"DELETE FROM Temp"];
    char *err;
    if (sqlite3_exec(db, [ssql UTF8String], NULL, NULL, &err) != SQLITE_OK) 
    {
        sqlite3_close(db);
        NSAssert(0, @"Error deleting table."); 
    } 
}

//Close database
-(void) closeDB
{
    sqlite3_close(db);
}


@end
