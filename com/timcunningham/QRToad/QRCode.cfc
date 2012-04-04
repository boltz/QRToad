<cfcomponent hint=	"Utilizes QR barcode functions of the latest versions of itext. 
					Download the latest version from http://itextpdf.com 
					put the itext JAR in your ColdFusion class path. 
					Restart ColdFusion service">
<cfset QR = createObject("java","com.itextpdf.text.pdf.BarcodeQRCode")>
<cfset color = createObject("java","java.awt.Color")>
<cfset goodColorList = 	"BLACK,BLUE,CYAN,DARK_GRAY,GRAY,GREEN,LIGHT_GRAY,MAGENTA,ORANGE,PINK,RED,WHITE,YELLOW,
							black,blue,cyan,darkgray,gray,green,lightgray,magenta,orange,pink,red,white,yellow">

<cffunction name="init" access="public">
	<cfreturn this>
</cffunction>

<cffunction name="getQRCode" access="public">
	<cfargument name="data" 			type="string" 	required="true" 							hint="This is the string you want to encode to QR code"/>
	<cfargument name="width" 			type="numeric" 	required="true" default="150" 				hint="pixel width of the QR Code"/> 
	<cfargument name="height" 			type="numeric" 	required="true" default="150" 				hint="pixel height of the QR Code"/> 	
	<cfargument name="format" 			type="string"	required="true" default="png"				hint="png,jpg,gif">
	<cfargument name="foreGroundColor"	type="string"	rquired="true"	default="0,0,0,255"			hint="list with  R,B,G,Alpha settings or a color constant" >
	<cfargument name="backGroundColor"	type="string"	rquired="true"	default="255,255,255,255"	hint="list with  R,B,G,Alpha settings or a color constant" >
	<cfargument name="CorrectionLevel"	type="any"		required="true" default=""					hint="TBD">
	
	<cfset var fg = "">
	<cfset var bg = "">
	<cfset var qrCode 	= setQRCode(arguments.data, arguments.width, arguments.height, arguments.CorrectionLevel)>
	<cfset fg 			= setColor(arguments.foreGroundColor)>
	<cfset bg 			= setColor(arguments.backGroundColor)>
	<cfset var imgAWT 	= createAwtImage(fg,bg)>
	<cfset var finalimg	= ToBinaryImage(imgAWT,arguments.format)>
	<cfreturn finalImg>
</cffunction>

<!--- BarcodeQRCode Methods --->
<cffunction name="createAWTImage" access="private">
	<cfargument name="foreground" required="true" hint="Color of foreground should be a java.awt.color object">
	<cfargument name="background" required="true" hint="Color of background should be a java.awt.color object">
	
	<cfset var imgAWT = QR.createAwtImage(arguments.foreground, arguments.background)>
	<cfreturn imgAWT>	
</cffunction>

<cffunction name="getImage">
	<cfreturn qr.getImage()>
</cffunction>


<!--- Supporting Function for Itext BarcodeQRCode --->
<cffunction name="setColor" access="private">
	<cfargument name="colorInfo" type="string" required="true">
	<cfif find(",", arguments.colorInfo)>
		<cfreturn setColorByNumber(listGetAt(arguments.colorInfo,1),listGetAt(arguments.colorInfo,2),listGetAt(arguments.colorInfo,3),listGetAt(arguments.colorInfo,4))>
	</cfif>
	<cfreturn setColorByname(arguments.colorInfo)>
	
</cffunction>

<cffunction name="setColorByNumber" access="private">
	<cfargument name="red" 		type="numeric" required="true" hint="0-255"/>
	<cfargument name="green" 	type="numeric" required="true" hint="0-255"/>
	<cfargument name="blue" 	type="numeric" required="true" hint="0-255"/>
	<cfargument name="alpha" 	type="numeric" required="true" hint="0-255"/>
	<cfset var returnColor = Color.init(JavaCast("int",arguments.red),JavaCast("int",arguments.green),JavaCast("int",arguments.blue),JavaCast("int",arguments.alpha))/>
	<cfreturn returnColor/>
</cffunction>

<cffunction name="setColorByname" access="private">
	<cfargument name="name" type="string" required="true"> 

	<cfif listFindNoCase(goodColorList,arguments.name) IS False>
		<cfthrow message="#arguments.name# is an invalid Color Name. Accepts: #goodColorList#">
	</cfif>
	<cfreturn color[arguments.name]>
</cffunction>

<cffunction name="setQRCode" access="private">
	<cfargument name="data" 			type="string" 	required="true" 					hint="This is the string you want to encode to QR code"/>
	<cfargument name="width" 			type="numeric" 	required="true" 	default="100" 	hint="pixel width of the QR Code"/> 
	<cfargument name="height" 			type="numeric" 	required="true" 	default="100" 	hint="pixel height of the QR Code"/> 
	<cfargument name="errorCorrection"	type="any"		required="true" 	default=""		hint="TBD">
	
	<cfset QR = QR.init(arguments.data,arguments.width,arguments.height,JavaCast('null',''))>
	<cfreturn QR>
</cffunction>

<cffunction name="ToBinaryImage" access="private">
	<cfargument name="image" 	type="any"	required="true">
	<cfargument name="format" 	type="string"		required="true" hint="png,jpg,gif">
	
	<cfif checkExtension(arguments.format) IS false>
		<cfthrow message="Image format must be png,jpg, or gif">
	</cfif>
	<cfset var binaryImage 	= "">
	<cfset var cfNewImage 	= imageNew("",getWidth(arguments.image),getHeight(arguments.image), "argb")> 
	<cfset var graphics 	= ImageGetBufferedImage(cfNewImage).getgraphics()>
	<cfset graphics.drawImage(arguments.image, 0, 0, javacast("null", ""))>
	<cfset var imagePath = "ram://" & createUUID() & "." & arguments.format> 	<!--- <cfset imagepath = expandPath("test.png")> --->
	<cfset imageWrite(cfNewImage, imagePath)>
	<Cfset graphics.dispose()>
	<cffile action="readbinary" file="#imagePath#" variable="binaryImage" >
	<cffile action="delete" file="#imagePath#"> 
	<cfreturn  binaryImage>
</cffunction>

<cffunction name="checkExtension" access="private" >
	<cfargument name="extension" type="string" required="true" default="png">
	<cfif listFindNoCase("png,jpg,gif",arguments.extension) IS false>
		<cfreturn false>
	</cfif>
	<cfreturn true>
</cffunction> 

<!--- ToolkitImage functions --->
<cffunction name="flush" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.flush()>
</cffunction>

<cffunction name="getBufferedImage" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getBufferedImage()>
</cffunction>

<cffunction name="getColorModel" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getColorModel()>
</cffunction>

<cffunction name="getGraphics" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getGraphics()>
</cffunction>

<cffunction name="getHeight" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getHeight()>
</cffunction>

<cffunction name="getImageRep" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getImageRep()>
</cffunction>

<cffunction name="getSource" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getSource()>
</cffunction>

<cffunction name="getWidth" access="private">
	<cfargument name="image" type="any" >
	<cfreturn image.getWidth()>
</cffunction>

<!---
********************************************************************************************************************************
******************************* Licensed under the MIT – No Bob Saget Open Source License ***************************************
**************************************** Copyright (c) 2012 Timothy Cunningham   ***********************************************
********************************************************************************************************************************
Permission is hereby granted, free of charge, to any person (except for Bob Saget) obtaining a copy of this software 			
and associated documentation files (the “Software”), to deal in the Software without restriction, including without 			
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,			
 and to permit persons to whom the Software is furnished to do so, subject to the following conditions:							
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.	
Under no circumstances shall Bob Saget be granted use of this software, source code, documentation or other related material.	
 Persons dealing in the Software agree not to knowingly distribute these materials or any derivative works to Bob Saget.		
 																																
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 				
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 										
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 				
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 							
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 																					
********************************************************************************************************************************
********************************************************************************************************************************
********************************************************************************************************************************
--->
</cfcomponent>