<!--- include globals ---> 
<cfinclude template="../includes/app_globals.cfm">
  
<!--- define TIMENOW --->

<cfset current_page="buyers">
<cfmodule template="../functions/timenow.cfm">
<!-- chk IEscrow enabled/disabled -->
<cfmodule template="../functions/iescrow.cfm"
  sOpt="ChkStatus">

<html>
  <head>
    <title>Buyer Information</title>
    
    <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
  </head>
  
  <!--- Include the body tag --->
   <cfinclude template="../includes/bodytag.html"> 
<cfinclude template="../includes/menu_bar.cfm">
    <div align="center">

   <table border=0 cellspacing=0 cellpadding=2 width=800>
        <tr>
          <td><font size=4><b>Buyer Information</b></font></td>
        </tr>
        <tr>
          <td><hr width=100% size=1 color="<cfoutput>#heading_color#</cfoutput>" noshade></td>
        </tr>
        <tr>
          <td>
            <font size=3>
              Bidding on and buying items online can be a rewarding experience.  As an 
              online consumer you will wish to conduct yourself as you would in making a 
              purchase anywhere.  Here is some information which will help you through 
              the process.<br>
              <br>
              
              <table border=1 cellspacing=0 cellpadding=5 width=100%>
                
                <!--- Use this code to specify additional items of information
                <tr bgcolor="000080">
                  <td>
                    <font color="ffffff">
                      <b>Heading Here</b>
                    </font>
                  </td>
                </tr>
                <tr>
                  <td>
                    Information Here<br>
                    <br>
                  </td>
                </tr>
                --->
                
                <cfoutput><tr bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#"></cfoutput>
                  <td>
                      <b>Know The Items You Are Bidding For</b>
                  </td>
                </tr>
                <tr>
                  <td>
                    Items listed on this site are most often posted by individuals, 
                    and sometimes small companies. While we try and regulate our site 
                    and remove objectionable material or listings, we cannot be responsible 
                    for regulating or verifying every item for sale.  You need to be aware 
                    of the potential for misleading statements or fraud of a listed item, or 
                    the possibility of purchasing an illegal product.<br>
                    <br>
                    
                    You can minimize your risk by e-mailing the seller with specific questions 
                    related to the item and checking out the seller's feedback report compiled 
                    by other individuals who have purchased from this person/company.<br>
                    <br>
                   <!---  <cfif hIEscrow.bEnabled>
                    Also, consider using safe, easy-to-use eNetSettle services at the end of auction.  
                    <a href="<cfoutput>#VAROOT#</cfoutput>/help/faqIEscrow.cfm">eNetSettle services</a>, 
                    such as <a href="http://www.enetsettle.com">eNetSettle</a>, provide 
                    security by keeping custody of your funds and releasing them to the seller only 
                    when specified conditions are met.<br>
                    <br>
					</cfif> --->
                  </td>
                </tr>
                <cfoutput><tr bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#"></cfoutput>
                  <td>
                      <b>User Agreement</b>
                  </td>
                </tr>
                <tr>
                  <td>
                    Please read our <A HREF="<cfoutput>#VAROOT#</cfoutput>/registration/user_agreement.cfm">User Agreement</A> 
                    which outlines the site policies and terms of use.<br>
                    <br>
                  </td>
                </tr>
                <cfoutput><tr bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#"></cfoutput>
                  <td>
                      <b>Bidding on Items</b>
                  </td>
                </tr>
                <tr>
                  <td>
                    You should <A HREF="<cfoutput>#VAROOT#</cfoutput>/registration/index.cfm">register</A> 
                    before you start bidding on items. The bidding process that can be broken down 
                    into steps:
                    
                    <ol>
                    <li>Click on the item you are interested in from within a category or in the featured 
                        auction list.
                    <li>Scroll past the item description to the <b>Bidding</b> section.
                    <li>Enter your <b>User ID</b>, <b>Password</b>, <b>Quantity</b> and <b>Your Bid</b>.
                    <li>Click the Review Bid button and if everything is OK then submit your bid.
                    </ol>
                    <br>
                  </td>
                </tr>
                <cfoutput><tr bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#"></cfoutput>
                  <td>
                      <b>Personal Information</b>
                  </td>
                </tr>
                <tr>
                  <td>
                    You can check your <A HREF="<cfoutput>#VAROOT#</cfoutput>/personal/index.cfm">Personal Page</A> 
                    which allows you to do the following:
                    
                    <ul>
                    <li>View and edit your personal info.
                    <li>View your selling history.
                    <li>View your buying history.
                    <li>See your user feedback.
                    <li>Use the <B>Future Watch</B> feature.
                    <li>Relist your expired auctions.
                    <li>Edit your current Auction Items.
                    </ul>
                    <br>
                  </td>
                </tr>
              </table>
              
            </font>
          </td>
        </tr>
        </table><cfoutput>
<table border=0 cellpadding=2 cellspacing=0 width="#get_layout.page_width#">
        <tr>
          <td>
            <br>
            <br>
                        <hr width=#get_layout.page_width# size=1 color="#heading_color#" noshade>
          </td>
        </tr>
        <tr>
          <td align="left">
            
              <cfinclude template="../includes/copyrights.cfm">
          
          </td>
        </tr>
      </table></cfoutput></div>
    
  </body>
</html>