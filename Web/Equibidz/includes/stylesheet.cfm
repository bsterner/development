<cfsilent>
<!--- Get Link Colors --->
<cfset link_color = get_layout.link_color>      
<cfset alink_color = get_layout.alink_color>    
<cfset vlink_color = get_layout.vlink_color>
<cfset hlink_color = get_layout.hlink_color>
<cfset heading_font = get_layout.heading_font>
<cfset heading_color = get_layout.heading_color>
<cfset heading_fcolor = get_layout.heading_fcolor>
<cfset heading_fsize = get_layout.heading_fsize>
<cfset bg_color = get_layout.bg_color>
<cfset text_color = get_layout.text_color>
<cfset text_font = get_layout.text_font>
</cfsilent>
<cfoutput> 
				<cfsavecontent variable="style_var">
/*
Do not make changes to stylesheet.css! All changes must be made on stylesheet.cfm.
*/
body {color :#text_color#;
	font-size : 11px;
	font-family : #text_font#;}
a:link { color:#link_color#;
text-decoration:none;}
a:visited { color:#vlink_color#;
text-decoration:none;}
a:hover { color:#hlink_color#;
text-decoration:none;}
a:active { color : #alink_color#;
text-decoration:none;}


table {
	border-color : 616362;
	border-width ; 1px thin;
}

th {
	color : 616362;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
}

tr {
	border-color : 616362;
	border-width ; 1px thin;
}


input, select {
	color : ##000000;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.px {
	padding-top : 0px;
	padding-bottom : 0px;
	padding-left : 0px;
	padding-right : 0px;
	margin-top : 2px;
	margin-bottom : 0px;
	margin-left : 0px;
	margin-right : 0px;
}
.px5 {
	padding-top : 0px;
	padding-bottom : 0px;
	padding-left : 0px;
	padding-right : 0px;
	margin-top : 5px;
	margin-bottom : 0px;
	margin-left : 0px;
	margin-right : 0px;
}
.title01 {
	color : ##FFFFFF;
	margin-top : 10px;
	padding-bottom : 10px;
	margin-bottom : 0px;
	margin-left : 15px;
	margin-right : 15px;
	font-size : 13px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
	font-style: italic;
}
.title {
	color : ##FFFFFF;
	margin-top : 1px;
	padding-bottom : 1px;
	margin-bottom : 1px;
	margin-left : 37px;
	margin-right : 10px;
	font-size : 10px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.title a {
	color : ##EF6D00;
}

/*
.title a:hover {
	color : ##C25A02;
}
*/

.list {
	color : ##FFFFFF;
	margin-top : 3px;
	padding-bottom : 3px;
	margin-bottom : 0px;
	margin-left : 10px;
	margin-right : 10px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.right {
	color : ##000000;
	margin-top : 5px;
	padding-bottom : 10px;
	margin-bottom : 0px;
	margin-left : 15px;
	margin-right : 15px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.right a, .list a {
	color : ##FF7500;
}

/*
.right a:hover {
	color : ##AAAAAA;
}
*/

.left {
	color : ##000000;
	margin-top : 5px;
	padding-bottom : 5px;
	margin-bottom : 0px;
	margin-left : 15px;
	margin-right : 25px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.left b {
	color : ##FF6600;
}
.left a {
	color : ##FF6600;
}

/*
.left a:hover {
	color : ##FF0000;
}
*/

p {
	color : ##000000;
	margin-top : 5px;
	padding-bottom : 10px;
	margin-bottom : 0px;
	margin-left : 20px;
	margin-right : 20px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
}
p a {
	color : ##000000;
}

/*
p a:hover {
	color : ##294A7B;
}
*/

.menu01 {
	color : ##000000;
	margin-top : 1px;
	padding-bottom : 1px;
	margin-bottom : 0px;
	margin-left : 10px;
	margin-right : 10px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
}
.menu01 a {
	color : ##000000;
	text-decoration: none;
}

/*
.menu01 a:hover {
	color : ##555555;
}
*/

.menu02 {
	color : ##FFFFFF;
	margin-top : 5px;
	padding-bottom : 5px;
	margin-bottom : 0px;
	margin-left : 20px;
	margin-right : 20px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
	font-weight: bold;
}
.menu02 a {
	color : ##FFFFFF;
	text-decoration: none;
}

/*
.menu02 a:hover {
	color : ##DDDDDD;
}
*/

.bar01 {
	color: ##OOOOOO;
	margin-top: 1px;
	padding-bottom: 1px;
	margin-bottom: 0px;
	margin-left: 3px;
	margin-right: 18px;
	font-size: 18px;
	font-family: Arial,Tahoma,Verdana;
	font-weight: bold;
}
.b01 {
	color : ##000000;
	margin-top : 2px;
	padding-bottom : 1px;
	margin-bottom : 1px;
	margin-left : 18px;
	margin-right : 0px;
	font-size : 11px;
	font-family : Tahoma,Verdana,Arial;
}
.b01 a {
	color : ##000000;
	text-decoration: none;
}

/*
.b01 a:hover {
	color : ##333333;
}
*/
				</cfsavecontent>
			</cfoutput>
			
			<!--- Write a new stylesheet.css --->
      <cffile action="write" file=#expandPath ("..\includes\stylesheet.css")# output="#style_var#">