<cfparam  name="url.data"  default="No data passed">
<cfset qr = createObject("component","com.timcunningham.QRToad.QRCode")>
<cfcontent reset="true" variable="#qr.getQRCode("#url.data#")#" type="image/png">


