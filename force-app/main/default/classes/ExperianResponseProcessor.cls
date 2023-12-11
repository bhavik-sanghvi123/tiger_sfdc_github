/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: API response processor from Experian Third-Party

History
08/07/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/

public class ExperianResponseProcessor {
    public static CommonObjectWrapper.cls_ExperianAddress processReponse(HttpResponse formatResponse) {
        CommonObjectWrapper.cls_ExperianAddress expAddress = new CommonObjectWrapper.cls_ExperianAddress();
        
        if (formatResponse != null && formatResponse.getStatusCode() == 200) {
            AddressWrapper formatResponseWrap = (AddressWrapper)JSON.deserialize(formatResponse.getBody(), AddressWrapper.class);
            system.debug('================ format response wrap =======' + formatResponseWrap);
            //List<AddressWrapper.cls_Components> formatResultList = formatResponseWrap.components;
            AddressWrapper.Result formatResult = formatResponseWrap.result;
            AddressWrapper.cls_Components resultComponents = formatResult.components;
            AddressWrapper.cls_Sub_Building cmpSubBuilding = resultComponents.sub_building;
            AddressWrapper.cls_Building cmpBuilding = resultComponents.building;
            AddressWrapper.cls_Street cmpStreet = resultComponents.street;
            AddressWrapper.cls_Locality cmpLocality = resultComponents.locality;
            AddressWrapper.cls_Town cmpTown = cmpLocality.town;
            AddressWrapper.cls_Postal_Code cmpPostalCode = resultComponents.postal_code;
            system.debug('================ resultcomponents =======' + resultComponents);
           
            if(resultComponents != null) {
            
                expAddress.expStreet1 = null;
                expAddress.expBuilding = null;
                expAddress.expState = null;
                expAddress.expPostCode = null;
                expAddress.expSubBuilding = null;

                if(cmpBuilding.building_name != null) {
                    expAddress.expBuilding = cmpBuilding.building_name;
                    
                }
                
                if(cmpBuilding.building_number != null) {
                    expAddress.expStreet1 = cmpBuilding.building_number;
                    
                }

                if(cmpStreet.name != null) {
                    expAddress.expStreet1 = expAddress.expStreet1 + ' ' + cmpStreet.name;
                    
                }
                
                if(cmpTown.name != null) {
                    expAddress.expState = cmpTown.name;
                    
                }
                
                if(cmpPostalCode.primary != null) {
                    expAddress.expPostCode = cmpPostalCode.primary;
                    
                }

                if(cmpSubBuilding != null){
                    if(cmpSubBuilding.name != null) {
                        String unitnumber = cmpSubBuilding.name;
                        expAddress.expSubBuilding = unitnumber.substring(1, unitnumber.length()); //remove #
                        system.debug('================ unit number =======' + expAddress.expSubBuilding);
                    }
                }
            } 
        }

        return expAddress;
    }
}