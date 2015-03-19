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
	        sObjectSimpleWrapper sObjectInfo = getFieldsList(sObjectVar);
	        
	        //build SOQL
	        String sObjectName = sObjectInfo.name;
	        String fieldList = sObjectInfo.fieldList;
	        String dynQuery = buildSOQL(sObjectName, fieldList, whereClause);
	        
	        //excute SOQL
	        list<SObject> records = Database.query(dynQuery);
	        
	        //serialize records
	        return serializeRecords(records);	        
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
    private static sObjectSimpleWrapper getFieldsList(Schema.SobjectType sObjectVar)
    {    	
    	Schema.DescribeSObjectResult dsr = sObjectVar.getDescribe();
    	String sObjectName = dsr.getName();
    	Map <String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
       	list<String> lstFields = new list<String>();
        lstFields.addAll(fieldMap.keySet());
        String fieldList = String.join(lstFields,',');
        sObjectSimpleWrapper sObjectInfoInstance = new sObjectSimpleWrapper(sObjectName, fieldList); 
        return sObjectInfoInstance;
    }
    
    /**
    *@MethodName : buildSOQL 
    *@param      : String sObjectName, String fieldList, String whereClause
    *@Description: build SOQL string
    **/
    private static string buildSOQL(String sObjectName, String fieldList, String whereClause)
    {
    	 //Form the basic query
        String dynQuery = string.format('SELECT {0} FROM {1}', new list<string>{fieldList, sObjectName});

        //add where clause   
        if(!isNullOrBlank(WhereClause)) dynQuery = string.format('{0} WHERE {1}', new list<string>{dynQuery, whereClause});
        
        return dynQuery;
    }
    
     /**
    *@MethodName : serializeRecords 
    *@param      : list<sObject> records
    *@Description: serialize sObject records into JSON
    **/
    private static string serializeRecords(list<sObject> records)
    {
    	String recordsJson = JSON.serialize(records);    	
    	return recordsJson;
    }
     
     /**
    *@MethodName : getErrorJson 
    *@param      : String errorMsg
    *@Description: send JSON error Msg
    **/
    private static string getErrorJson(String errorMsg)
    {
    	return string.format('[{"message":"error : {0}"}]', new string[]{errorMsg});	
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
        
    private class sObjectSimpleWrapper
    {
    	String name, fieldList;
    	
    	public  sObjectSimpleWrapper(String name, String fieldList)
    	{
    		this.name = name;
    		this.fieldList = fieldList;	
    	}	
    }
}