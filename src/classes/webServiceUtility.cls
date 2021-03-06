public with sharing class webServiceUtility
{
    /**
    *@MethodName : getRecords 
    *@param      : String sObjectName, String whereClause
    *@Description: To Query all the fields of a specified sObject and serialize the data
    **/
	public static string getRecords(Schema.SobjectType sObjectVar, String whereClause)
	{           
		try
		{
		    //get fields list 
		    sObjectBasicInfo basicInfo = getSObjectBasicInfo(sObjectVar);
		    
		    //build SOQL		   
		    String dynQuery = buildSOQL(basicInfo, whereClause);
		    
		    //excute SOQL
		    list<SObject> records = Database.query(dynQuery);
		    
		    //serialize records
		    return serializeRecords(basicInfo, records);	        
		 }
		 catch(Exception ex)
		 {          		 	
		   return getErrorJson(ex.getMessage());
		 }		
	}
    
    /**
    *@MethodName : getFieldsList 
    *@param      : Schema.SobjectType sObjectVar
    *@Description: get sObject info like it's name and fields.
    **/
    private static sObjectBasicInfo getSObjectBasicInfo(Schema.SobjectType sObjectVar)
    {    	    	
    	Schema.DescribeSObjectResult dsr = sObjectVar.getDescribe();
    	String sObjectName = dsr.getName();
    	Map <String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
       	list<String> lstFields = new list<String>();
        lstFields.addAll(fieldMap.keySet());
        String fieldList = String.join(lstFields,',');
        sObjectBasicInfo sObjectInfoInstance = new sObjectBasicInfo(sObjectName, fieldList); 
        return sObjectInfoInstance;
    }
    
    /**
    *@MethodName : buildSOQL 
    *@param      : String sObjectName, String fieldList, String whereClause
    *@Description: build SOQL string
    **/
    private static string buildSOQL(sObjectBasicInfo basicInfo, String whereClause)
    {
    	 //Form the basic query
        String dynQuery = string.format('SELECT {0} FROM {1}', new list<string>{basicInfo.fieldList, basicInfo.name});

        //add where clause   
        if(!isNullOrBlank(WhereClause)) dynQuery = string.format('{0} WHERE {1}', new string[]{dynQuery, whereClause});
        
        return dynQuery;
    }
    
     /**
    *@MethodName : serializeRecords 
    *@param      : list<sObject> records
    *@Description: serialize sObject records into JSON
    **/
    private static string serializeRecords(sObjectBasicInfo basicInfo, list<sObject> records)
    {
    	String recordsJson = JSON.serialize(records);
    	String formattedJson = '[{"message":"success","totalSize":"'+ string.valueOf(records.size()) + '","' + basicInfo.name + '":' + recordsJson + '}]';    	
    	return formattedJson;
    }
     
     /**
    *@MethodName : getErrorJson 
    *@param      : String errorMsg
    *@Description: send JSON error Msg
    **/
    private static string getErrorJson(String errorMsg)
    {
    	return '[{"message":"Error Occurred -' + errorMsg + '"}]';
    }
    
    /**
    *@MethodName : isNullOrBlank
    *@param      : value
    *@Description: To find if the value is null or blank
    **/
    private static boolean isNullOrBlank(String value)
    {
        return (value == NULL || value.trim() == '');
    }
        
    private class sObjectBasicInfo
    {
    	String name, fieldList;
    	
    	public  sObjectBasicInfo(String name, String fieldList)
    	{
    		this.name = name;
    		this.fieldList = fieldList;	
    	}	
    } 
}