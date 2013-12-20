#import "CsvToSqliteTests.h"
#import <CsvToSqlite/CsvToSqlite-Framework.h>

#import "CsvInitializationError.h"

#import <objc/message.h>

@implementation CsvToSqliteTests

-(void)setUp
{
    self.defaultSchema = @{ @"Date" : @"DATETIME" };
}

-(void)testConverterRejectsInit
{
    XCTAssertThrows( [ CsvToSqlite new ], @"init should not be supported" );
}

-(void)testConverterRequiresDatabaseName
{
    CsvToSqlite* converter_ = nil;
    NSDictionary* schema_ = self.defaultSchema;

    {
        converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: nil
                                                     dataFileName: @"data file stub"
                                                   databaseSchema: schema_
                                                       primaryKey: nil
                                                    defaultValues: nil ];
        XCTAssertNil( converter_, @"nil expected - DatabaseName" );
    }

    {
        converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                     dataFileName: nil
                                                   databaseSchema: schema_
                                                       primaryKey: nil
                                                    defaultValues: nil];
        XCTAssertNil( converter_, @"nil expected - DatabaseName" );
    }

    {
        converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @""
                                                     dataFileName: @"data file stub"
                                                   databaseSchema: schema_
                                                       primaryKey: nil
                                                    defaultValues: nil];
        XCTAssertNil( converter_, @"nil expected - DatabaseName" );
    }
   
    {
        converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                     dataFileName: @""
                                                   databaseSchema: schema_
                                                       primaryKey: nil
                                                    defaultValues: nil];
        XCTAssertNil( converter_, @"nil expected - DatabaseName" );
    }
}

-(void)testConverterInitializedCorrectly
{
   NSDictionary* schema_ = self.defaultSchema;
   
   CsvToSqlite* converter_ = nil;   
   NSString* dbFile_       = nil;
   NSString* dataFile_     = nil;
   
   
   {
      dbFile_   = @"db stbu"  ;
      dataFile_ = @"data stub";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ 
                                                 databaseSchema: schema_ 
                                                     primaryKey: nil 
                                                  defaultValues: nil ];
      
      XCTAssertEqual( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      XCTAssertEqual( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }
   
   {
      dbFile_   = @"abra"   ;
      dataFile_ = @"kadabra";
      
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: dbFile_
                                                   dataFileName: dataFile_ 
                                                 databaseSchema: schema_
                                                     primaryKey: nil
                                                  defaultValues: nil];
      
      XCTAssertEqual( dbFile_  , converter_.databaseName, @"databaseName mismatch" );
      XCTAssertEqual( dataFile_, converter_.dataFileName, @"dataFileName mismatch" );
   }
}

-(void)testConverterRequiresDbScheme
{
   CsvToSqlite* converter_ = nil;      
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"file stub" 
                                                 databaseSchema: nil 
                                                     primaryKey: nil 
                                                  defaultValues: nil];
      XCTAssertNil( converter_, @"nil expected - DatabaseName" );
   } 
   
   {
      converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"db stub"
                                                   dataFileName: @"file stub" 
                                                 databaseSchema: self.defaultSchema 
                                                     primaryKey: nil ];
      XCTAssertNotNil( converter_, @"nil expected - DatabaseName" );
   }   
}

-(void)testStoreDataCrashesWithNullError
{
   CsvToSqlite* converter_ = nil;
   
   converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"a"
                                                dataFileName: @"b" 
                                              databaseSchema: self.defaultSchema
                                                  primaryKey: nil ];
   
   XCTAssertThrows( [ converter_ storeDataInTable: @"Values" 
                                           error: NULL ], @"NSAssert expected" );
}

-(void)testStoreDataReturnsErrorForInvalidTableName
{
   NSError* error_ = nil;
   CsvToSqlite* converter_ = nil;
   BOOL result_ = YES;
   
   converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"a"
                                                dataFileName: @"b" 
                                              databaseSchema: self.defaultSchema 
                                                  primaryKey: nil ];
   
   {
      result_ = [ converter_ storeDataInTable: nil 
                                        error: &error_ ];
      
      XCTAssertFalse( result_, @"Unexpected success" );
      XCTAssertEqual( error_.domain, @"org.EmbeddedSources.CSV.import", @"error domain mismatcg" );
      XCTAssertEqual( error_.code, 1, @"error code mismatch" );
   }
   
   {
      result_ = [ converter_ storeDataInTable: @"" 
                                        error: &error_ ];
      
      XCTAssertFalse( result_, @"Unexpected success" );
      XCTAssertEqual( error_.domain, @"org.EmbeddedSources.CSV.import", @"error domain mismatcg" );
      XCTAssertEqual( error_.code, 1, @"error code mismatch" );
   }   
}

-(void)testStoreRequiresColumnParser
{
    CsvToSqlite* converter_ = nil;
    NSError* error_ = nil;
    
    converter_ = [ [ CsvToSqlite alloc ] initWithDatabaseName: @"a"
                                                 dataFileName: @"b" 
                                               databaseSchema: self.defaultSchema
                                                   primaryKey: nil ];
    
    typedef void (*SetColumnParserMsgSendFunction)( id, SEL, id );
    static const SetColumnParserMsgSendFunction setColumnsParser = (SetColumnParserMsgSendFunction)objc_msgSend;
    
    setColumnsParser( converter_, @selector( setColumnsParser: ), nil );
    
    BOOL result_ = [ converter_ storeDataInTable: @"Values" 
                                           error: &error_ ];
        
    XCTAssertFalse ( result_, @"error expected" );
    XCTAssertNotNil( error_ , @"error expected" );
    
    XCTAssertTrue( [ error_ isMemberOfClass: [ CsvInitializationError class ] ], @"error class mismatch" );
}

@end
