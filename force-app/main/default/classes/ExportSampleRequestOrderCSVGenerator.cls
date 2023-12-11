public with sharing class ExportSampleRequestOrderCSVGenerator {
    public static String generateCSV(List<OrderExport2__c> esroList) {
        String generatedCSVFile ='';
        generatedCSVFile = genereateHeader().removeEnd(',') + '\n';
        String fileRow;
        
        for(OrderExport2__c esro : esroList){
            fileRow = '"' + esro.Name__c + '"';
            fileRow = fileRow +','+ '"' + esro.Street_1__c + '"';
            fileRow = fileRow +','+ '"' + esro.Street_2__c + '"';
            fileRow = fileRow +','+ '"' + esro.UnitNumber__c + '"';
            fileRow = fileRow +','+ '"' + esro.PostalCode__c + '"';
            fileRow = fileRow +','+ '"' + esro.Mobile__c + '"';
            
            if(esro.Product_Code__c == 'G315'){
                fileRow = fileRow +','+ 'G314';
            }else if(esro.Product_Code__c == 'G338'){
                fileRow = fileRow +','+ 'G337';
            }else{
                fileRow = fileRow +','+ '"' + esro.Product_Code__c + '"';
            }
            fileRow = fileRow +','+ '"' + esro.Quantity__c + '"';
            fileRow = fileRow +','+ '"' + esro.Order_Number__c + '"';
            
            generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
        }
        return generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
    }

    public static String formatCSVDate(date value) {
        String result;
        result = String.valueOf( value.day() ).length() == 1 ? '0' + value.day() :  String.valueOf( value.day() );
        result = String.valueOf( value.month() ).length() == 1 ? result + '/0' + value.month() : result + '/' + value.month();
        result = result + '/' + String.valueOf( value.year() );
        return result;
    }

    public static String formatString(String value) {
        return String.isEmpty(value) ? '' : value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
    }

    public static String forceString(String value) {
        String result = '';
        if (!String.isEmpty(value) && value.contains(','))   {
            result =  value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
        } else if (!String.isEmpty(value)){
            result = '\'' + value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
        }  
        return result;
    }

    public static String genereateHeader() {
        List<String> headerArray = new List<String>();
        headerArray.add('Name');
        headerArray.add('Street 1');
        headerArray.add('Street 2');
        headerArray.add('Unit Number');
        headerArray.add('Postal Code');
        headerArray.add('Mobile');
        headerArray.add('Product Code');
        headerArray.add('Quantity');
        headerArray.add('Order Number');

        return string.join(headerArray, ',');
    }
}