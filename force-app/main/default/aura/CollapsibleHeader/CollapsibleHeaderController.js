({
    handleSectionClick : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));

        var sectionContainer = component.find('collapsibleSection');
        $A.util.toggleClass(sectionContainer, "slds-is-open");
    }
})