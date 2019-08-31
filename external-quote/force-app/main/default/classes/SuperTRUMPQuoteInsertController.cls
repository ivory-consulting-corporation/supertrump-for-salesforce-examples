public class SuperTRUMPQuoteInsertController {

    private ApexPages.StandardController controller { get; set; }

    public SuperTRUMPQuoteInsertController(ApexPages.StandardController controller){
        this.controller = controller;
    }
    
    public List<SelectOption> getTemplateOptions(){
        List<IST__SuperTRUMP_Template__c> templates = [SELECT ID, Name FROM IST__SuperTRUMP_Template__c ORDER BY Name LIMIT 50000];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '- Select One -'));
        for (IST__SuperTRUMP_Template__c t : templates){
            // In visualforce you get the 15 character version, while in Apex the 18 character version
            String value = String.valueOf(t.ID).substring(0, 15);
            options.add(new SelectOption(value, t.Name));
        }
        return options;
    }
}