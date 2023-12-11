/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Wrapper class for Experian Addresses
History
07/31/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
public class AddressWrapper {
    /*@AuraEnabled public List<cls_Results> results { get;set; }
    @AuraEnabled public List<cls_Components> components { get;set; }*/
    
    /*public class cls_Results{
      @AuraEnabled public String suggestion { get;set; }
      @AuraEnabled public String format { get;set; }
    }
    
    public class cls_Components{
      @AuraEnabled public String building1; // building > building name
      @AuraEnabled public String streetNumber1; // building > building number
      @AuraEnabled public String street1; // street > name
      @AuraEnabled public String locality1; // locality > town > name
      @AuraEnabled public String postalCode1; // postal_code > primary
    }*/

    public Result result;

    public class result{
      @AuraEnabled public List<cls_Suggestions> suggestions { get;set; }
      public cls_Components components;
    }

    public class cls_Suggestions{
      @AuraEnabled public String text { get;set; }
      @AuraEnabled public String format { get;set; }
    }
    
    public class cls_Address{
      @AuraEnabled public String address_line_1 { get;set; }
    }

    public class cls_Components{
      public cls_Sub_Building sub_building;
      public cls_Building building;
      public cls_Street street;
      public cls_Locality locality;
      public cls_Postal_Code postal_code;
    }

    public class cls_Sub_Building{
      @AuraEnabled public String name { get;set; }
    }

    public class cls_Building{
      @AuraEnabled public String building_name { get;set; }
      @AuraEnabled public String building_number { get;set; }
    }

    public class cls_Street{
      @AuraEnabled public String name { get;set; }
    }

    public class cls_Locality{
      public cls_Town town;
    }

    public class cls_Town{
      @AuraEnabled public String name { get;set; }
    }

    public class cls_Postal_Code{
      @AuraEnabled public String primary { get;set; }
    }  

  }