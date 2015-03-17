public with sharing class webServiceUtility
{
    /**
    *@MethodName : getRecords 
    *@param      : String sObjectName, String whereClause
    *@Description: To Query all the fields of a specified sObject and serialize the data
    **/
    public static string getRecords(String sObjectName, String whereClause)
    {           
        string errorFormat = '[{"Error": "{0}"}]';
        
        if(isNullOrBlank(sObjectName) || isNullOrBlank(whereClause)) return string.format(errorFormat, new list<string>{'Insufficient Parameters'});      
         
        //get meta info of all objects from the Org.
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        //describe the fields of a particular Sobject
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
      
        String strFields = '';

        //create comma seperated string of field api names
        for(String strFieldsInd : fieldMap.keySet())
        {
            strFields += strFieldsInd +', ';
        }

        //remove the trailing ',' 
        strFields = strFields.substring(strFields.length()-2, strFields.length()) == ', ' ? strFields.subString(0, strFields.length()-2) : strFields;
        
        //Form the basic query
        String strQuery = string.format('SELECT {0} FROM {1}', new list<string>{strFields, sObjectName});

        //add where clause   
        if(!isNullOrBlank(WhereClause)) strQuery = string.format('{0} WHERE {1}', new list<string>{strQuery, whereClause});
        
        String strJSONToReturn = '';
        try
        {
            List<SObject> lstSobjectRecords = Database.query(strQuery);
            strJSONToReturn = JSON.serializePretty(lstSobjectRecords);         
        }
        catch(JsonException jsonEx)
        {
            strJSONToReturn = string.format(errorFormat, new list<string>{jsonEx.getMessage()});
        } 
        catch(Exception ex)
        {
            strJSONToReturn = string.format(errorFormat, new list<string>{ex.getMessage()});
        }          
        return strJSONToReturn;
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
}