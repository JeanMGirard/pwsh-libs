https://developer.microsoft.com/en-us/graph/graph-explorer#

POST https://graph.microsoft.com/v1.0/me/messages

{
  "subject": "Annual review",
  "body": {
    "contentType": "HTML",
    "content": "You should be proud!"
  },
  "toRecipients": [
    {
      "emailAddress": {
        "address": "jean.m.girard@dimgo.net"
      }
    }
  ],
  "extensions": [
    {
      "@odata.type": "microsoft.graph.openTypeExtension",
      "extensionName": "net.dimgo.Referral",
      "companyName": "Dimgo Technologies",
      "expirationDate": "2015-12-30T11:00:00.000Z",
      "dealValue": 10000
    }
  ]
}



https://graph.microsoft.com/v1.0/me/extensions
{
  "@odata.type": "microsoft.graph.openTypeExtension",
  "extensionName": "com.contoso.roamingSettings",
  "theme": "dark",
  "color": "purple",
  "lang": "Japanese"
}
