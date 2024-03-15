global class receiveParametersOrg2 {
    webservice static String createContactRecord(String firstName, String lastName, String title, String email) {
        Contact rec = new Contact();
        rec.FirstName= firstName;
        rec.LastName=lastName;
        rec.Title=title;
        rec.Email=email;
        insert rec;
        return 'success';
    }
}