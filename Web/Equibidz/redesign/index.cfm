<!--- define cache control page
<cfset current_page = "indexhome">
<cfinclude template = "./includes/app_globals.cfm">



<!--- define TIMENOW --->
<cfmodule template="./functions/timenow.cfm">
 --->
<cfinvoke component="/CF-INF/cfc/HomePageRenderer" method="getPageModel" returnvariable="pageModel">

<!--- Set for convenience --->
<cfset variables.getLayout = application.getLayout>

<cfparam name="cookie.site_counter" default="0">
<cfif ListContains(cookie.site_counter, cr_set) is "FALSE">
    <cfset hits = #IncrementValue(getCounter.hit)#>
	<cfquery name="getHits" datasource="#DATASOURCE#">
		UPDATE stats
		SET hit = #hits#
		WHERE id=1
	</cfquery>
	<cfset item_cnt_list = listappend(cookie.site_counter, cr_set)>
	<cfcookie name="site_counter" value="#item_cnt_list#" expires="1">
<cfelse>
	<cfset hits = pageModel.getCounter.hit>
</cfif>

<cfif #getLayout.hits# eq 1>
	<font color=green size=1>This page has been viewed</font> <font size="3" color="Red"><b>#hits#</b></font><font color=green size=1>&nbsp;times.</font></td>
</cfif>

<!----------------------------- End all required queries --------------------------->
<cfoutput>
<html>
  <head>
    <title>Equibidz Auction</title>
    <meta name="keywords" content="#getLayout.keywords#">
    <meta name="description" content="#getLayout.descriptions#">
    <link rel=stylesheet href="/includes/stylesheet.css" type="text/css">
    <link rel=stylesheet href="/includes/stylenew.css" type="text/css">
  </head>
  <script language = "javascript">
		function popup(){
			var popup = window.open("","picWin","height=400,width=370,top=110,left=407")
					popup.document.write('<B><font face=Arial size=2>Reverse Auctions!</FONT></B><BR>')
					popup.document.write("<font face='Arial' size='2'><br>You've seen it used on top auction sites, now you can use it too - a Reverse Auction! Build a state-of-the-art marketplace on the web where everyone gets what they want. Buyers get the best prices and sellers make quick profits!<br><br>With a ")
					popup.document.write("<img src='images/r_reverse.gif' border='0'>")
					popup.document.write("\"reverse\" auction, prospective buyers can list any item that they wish to buy and then sellers bid to provide the best price. This concept is much more consumer oriented than a regular auction. The consumer decides the exact specifications of each item, instead of the specifications being dictated by the seller.<br><br>Buyers can find sellers who will offer the best prices on virtually any item. Sellers have access to an unlimited number of buyers who can compete for their business in an auction environment.<br><br>Reverse auctions can help corporate purchasing departments find the best deals for industrial parts and components, for example. No matter what the item is - tickets, raw material, services, etc. the reverse auction opens a gate to the world market for those who need merchandise and those willing to provide it.</font>")
					popup.document.close()
		}
  </script>
  <!--- Page body start here --->
  <body>
  <center>
  <table border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
  <!--- style="background-image: url('/images/bg_side1.jpg'); background-repeat: yes;"--->
  <td width="150" valign="top" class="tbl-sidecolor">
    <cfinclude template="includes/menu_bg1.cfm">
    <div style="border-right:1px; height:1400px; width:150px;">
       <table width="100%" cellspacing="0" cellpadding="5" border="0">
          <tr height=4><td></td></tr>
          <cfset ctr = 1>
          <cfloop query="pageModel.getAds">
             <cfif #ctr# MOD 2>
                <tr><td align="left">
                    &nbsp;<a href="#webaddress#" target="_blank" title="#webaddress#"><img src="/advertise/images/#picture#" height=150 width=130 border=0></a>
                </td></tr>
             </cfif>
             <cfset ctr = ctr + 1>
          </cfloop>
       </table>
    </div>
  </td>
  <td width="700" align="left" valign="top">
     <cfinclude template="includes/menu_main.cfm">
     <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
	    <tr>
	    <!---<td>
		   <div class="site-text">

       	   </div>
	    </td>--->
	    </tr>
        <tr>
       	<td>
			<!--- New scipted banner --->
			<cfinclude template="/includes/equibidz_banner.cfm" />
		   <!--- Display banner images --->
		   <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">
		 	  <tr>
			    <td width="20">&nbsp;</td>
						<cfloop query="pageModel.getBanners">
						  <td><span class="body-text"><img src="/banners/#file_name#"  height="240" width="220" alt="" /></span></td>
						</cfloop>
				  <td width="20">&nbsp;</td>

			  </tr>
		   </table>
	    </td>
	    </tr>
	    <!---<tr>
	    <td>
   	      <font size="3" color="orange"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   	      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.</b></font>
	    </td>
	    </tr>--->
	    <tr>
	    <td>
		   <div class="body-text">
		     <table border="0" cellpadding="0" cellspacing="0" width="100%">
						<tr>
							<td width="390" valign="top">
								<p class="p1">
									EQUIBIDZ COMPANY
								</p>
								<p class="p2">
									Dear Valued Customers,
								</p>
								<p class="p2">
							       <cfoutput>#getLayout.main_content#</cfoutput>


                              </p>
								<p class="p2">

                                                                        Sincerely,

					          </p>
							        <p class="p2">

                                                                        Equibidz.com Owners


								</p>
								<p class="p2">

								</p>
							</td>
							<td width="10">&nbsp;</td>
							<td width="390" valign="top">
								<p class="p3">
										<cfoutput>#getLayout.side_content#</cfoutput>

								</p>
                                                                <img height="200" src="/banners/IMG_side1.JPG" style="margin-left:20px;">
                                                                <br><br>
                                                                <span style="margin-left: 70px; font-size: 18px;"><b>Featured Auction:<b>
                                                                </span>
								<p class="p3">
                                                                 This spot will be available monthly at a special rate, please contact for the pricing on this special spot.

																 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
																 Web Ads are available for $30 for 1 Month, $55 for 2 Months, $75 for 3 Months, $90 for 4 Months, $105 for 5 Months and $115 for 6 Months.
								</p>
							</td>
						</tr>
			  </table>
		   </div>
		</td>
        </tr>
		<!--- Paypal Payment Information--->
		<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
		<input type="hidden" name="cmd" value="_s-xclick">
		<input type="hidden" name="hosted_button_id" value="5NGNYPRKXVJSN">
		<table>
		<tr><td><input type="hidden" name="on0" value="Horse Posting or WEB Ad Payment">Horse Posting or WEB Ad Payment</td></tr><tr><td><select name="os0">
			<option value="New Horse Posting">New Horse Posting $30.00 USD</option>
			<option value="Front Page Ad 1 Month">Front Page Ad 1 Month $30.00 USD</option>
			<option value="Front Page Ad 2 Months">Front Page Ad 2 Months $55.00 USD</option>
			<option value="Front Page Ad 3 Months">Front Page Ad 3 Months $75.00 USD</option>
			<option value="Front Page Ad 4 Months">Front Page Ad 4 Months $90.00 USD</option>
			<option value="Front Page Ad 5 Months">Front Page Ad 5 Months $105.00 USD</option>
			<option value="Front Page Ad 6 Months">Front Page Ad 6 Months $115.00 USD</option>
		</select> </td></tr>
		</table>
		<input type="hidden" name="currency_code" value="USD">
		<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_paynowCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
		<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
		</form>
		<tr>
		  <td align="center">
            <cfinclude template="/includes/inc_footer.cfm">
		  </td>
	    </tr>
     </table>
  </td>
  <!--- style="background-image: url('/images/bg_side2.jpg'); background-repeat: yes;"--->
  <td width="150" valign="top" class="tbl-sidecolor">
  <!---<cfinclude template="includes/menu_bg2.cfm">--->
  <cfinclude template="includes/menu_bg1.cfm">
  <div style="border-right:1px; height:1400px; width:150px;">
       <table width="100%" cellspacing="0" cellpadding="5" border="0">
          <tr height=4><td></td></tr>
          <cfset ctr = 1>
          <cfloop query="pageModel.getAds">
             <cfif not #ctr# MOD 2>
                <tr><td align="right">
                    <a href="#webaddress#" target="_blank" title="#webaddress#"><img src="/advertise/images/#picture#" height=150 width=130 border=0></a>&nbsp;
                </td></tr>
             </cfif>
             <cfset ctr = ctr + 1>
          </cfloop>
       </table>
  </div>
  </td>
  </tr>
  </table>
  </body>
  <!--- END Content Table consisting of 3 Columns --->
  <script language="javascript">
			function stoperror() {
				return true
			}
			window.onerror=stoperror();
  </script>
</html>
</cfoutput>
