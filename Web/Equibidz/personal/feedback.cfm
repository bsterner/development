 <!--- include globals --->
 <cfinclude template="../includes/app_globals.cfm">
<!--- Include session tracking template --->
 <cfinclude template="../includes/session_include.cfm">
<!--- define TIMENOW --->
 <cfmodule template="../functions/timenow.cfm">

 
 

 <!--- Check for invalid page access --->
 <cfif (#isDefined ("session.user_id")# is 0) or
       (#isDefined ("session.password")# is 0)>
  <cflocation url="/login.cfm?login=1&path=#script_name#">
 </cfif>

<cfquery username="#db_username#" password="#db_password#" name="get_PageGroup" datasource="#DATASOURCE#">
    SELECT pair AS itemsperpage
      FROM defaults
     WHERE name = 'itemsperpage'
</cfquery>

 <cfquery username="#db_username#" password="#db_password#" name="clear_list" datasource="#DATASOURCE#">
delete from stored where user_id=#session.user_id#

 </cfquery>

 <cfquery username="#db_username#" password="#db_password#" name="get_listing_bgcolor" datasource="#DATASOURCE#">
  SELECT pair
    FROM defaults
   WHERE name = 'listing_bgcolor'
 </cfquery>
 <cfset #header_bg# = #get_listing_bgcolor.pair#>

 <!--- get listing ending hours color --->
 <cfquery username="#db_username#" password="#db_password#" name="HrsEndingColor" datasource="#DATASOURCE#">
     SELECT pair AS color
       FROM defaults
      WHERE name = 'hrsending_color'
 </cfquery>

 <!--- get # of days item is new --->
 <cfquery username="#db_username#" password="#db_password#" name="ListingNew" datasource="#DATASOURCE#">
     SELECT pair AS days
       FROM defaults
      WHERE name = 'listing_new'
 </cfquery>

 <!--- get number of bids required for hot auction --->
 <cfquery username="#db_username#" password="#db_password#" name="HotAuction" datasource="#DATASOURCE#">
     SELECT pair AS bids
       FROM defaults
      WHERE name = 'bids4hot'
 </cfquery>

 <!--- get listing ending hours value --->
 <cfquery username="#db_username#" password="#db_password#" name="HrsEnding" datasource="#DATASOURCE#">
     SELECT pair AS hours
       FROM defaults
      WHERE name = 'hrsending'
 </cfquery>

 <!--- get listing ending hours color --->
 <cfquery username="#db_username#" password="#db_password#" name="HrsEndingColor" datasource="#DATASOURCE#">
     SELECT pair AS color
       FROM defaults
      WHERE name = 'hrsending_color'
 </cfquery>

 <!--- define listing row color --->
 <cfquery username="#db_username#" password="#db_password#" name="get_ListingColor" datasource="#DATASOURCE#">
     SELECT pair AS color
       FROM defaults
      WHERE name = 'listing_bgcolor'
 </cfquery>
 
 <!--- get thumbs mode settings (Thumbnail display outside studio) --->
<cfquery username="#db_username#" password="#db_password#" name="get_thumbsMode" datasource="#DATASOURCE#">
    SELECT pair AS show_thumbs
      FROM defaults
     WHERE name = 'enable_thumbs'
</cfquery>

 <cfoutput>

  






	


 <cfquery username="#db_username#" password="#db_password#" name="get_maxbid_item" datasource="#DATASOURCE#">
    SELECT DISTINCT bids.itemnum, items.itemnum
      FROM bids, items
     WHERE bids.user_id = #session.user_id#
     AND bids.itemnum = items.itemnum

	<!---  order by #sortorder1# --->
 </cfquery>
 <cfif get_maxbid_item.recordcount gt 0>
 	<cfset maxbid_items = valuelist(get_maxbid_item.itemnum)>
 <cfelse>
 	<cfset maxbid_items = 0>
 </cfif>
 <!--- ************************ --->

 

	 <cfloop index="i" list="#maxbid_items#">
	 <cfquery username="#db_username#" password="#db_password#" name="getwon_results" datasource="#DATASOURCE#" maxrows="20">
     SELECT items.itemnum, items.title, items.studio, items.featured_studio, bids.id, bids.bid, bids.time_placed, items.quantity,items.feedback_left, items.*
     FROM items, bids
     WHERE items.itemnum = #i#
	 AND items.itemnum = bids.itemnum

	 AND bids.user_id = #session.user_id#
	 AND bids.bid = (select max(bid) from bids where itemnum = #i# )
 and date_end < #timenow#
 	 	    order by date_end desc
	</cfquery>
	<cfif #getwon_results.recordcount# GT 0>
 
	<cfset item_count = 0>
        
         <cfloop query="getwon_results" >
         	
        

  <!--- increment item_count --->
          <cfset item_count = IncrementValue(item_count)>
        
          <!--- get bids --->
          <cfquery username="#db_username#" password="#db_password#" name="Countbids" datasource="#DATASOURCE#">
              SELECT COUNT(itemnum) AS total
                FROM bids
               WHERE itemnum = #itemnum#
          </cfquery>
        
          <!--- get highest bid --->
          <cfquery username="#db_username#" password="#db_password#" name="HighestBid" datasource="#DATASOURCE#">
              SELECT MAX(bid) AS price
                FROM bids
               WHERE itemnum = #itemnum#
			   AND user_id = #session.user_id#	   
          </cfquery>
          
          <!--- get highest bid --->
          <cfquery username="#db_username#" password="#db_password#" name="LowestBid" datasource="#DATASOURCE#">
              SELECT MIN(bid) AS price
                FROM bids
               WHERE itemnum = #itemnum#
			   AND user_id = #session.user_id#
          </cfquery>

 <cftry>
 <cfquery username="#db_username#" password="#db_password#" name="temp1" datasource="#DATASOURCE#">
   update items
   set totalbids1=#countbids.total#
   WHERE itemnum = #itemnum#
    
 </cfquery>

<cfcatch></cfcatch>
</cftry> 
 
<cfquery username="#db_username#" password="#db_password#" name="get_seller" datasource="#DATASOURCE#">
select i.user_id,U.user_id,u.nickname
from users u, items i
   WHERE i.itemnum = #itemnum# and i.user_id=U.user_id
    
 </cfquery>

 <cfquery username="#db_username#" password="#db_password#" name="insert" datasource="#DATASOURCE#">
insert into stored(user_id <cfif #get_seller.recordcount#>,user_id_from</cfif>,date_placed,itemnum,remote_ip,buyer,date_end) values(#session.user_id# <cfif #get_seller.recordcount#>,#get_seller.user_Id#</cfif>,#timenow#,#itemnum#,'#CGI.REMOTE_ADDR#',1,#createodbcdatetime(date_end)#)

    
 </cfquery>





</cfloop>

</cfif>
</cfloop>





 <cfquery username="#db_username#" password="#db_password#" name="cnt_auctions" datasource="#DATASOURCE#" >
      SELECT i.itemnum, i.status, i.title, i.picture, i.sound, i.minimum_bid, i.maximum_bid, i.bold_title, i.featured_cat, i.featured_studio, i.banner, i.banner_line, i.date_start, i.date_end, i.auction_mode,i.quantity
    FROM items i, bids b
   WHERE i.user_id = #session.user_id#
AND i.itemnum=b.itemnum
     AND (i.status = 0
          OR i.date_end < #TIMENOW#)
and b.winner=1
 order by i.title ASC
 </cfquery>
 



 <cfquery username="#db_username#" password="#db_password#" name="getsold_results" datasource="#DATASOURCE#" >
    SELECT i.itemnum, i.status, i.title, i.picture, i.sound, i.minimum_bid, i.maximum_bid, i.bold_title, i.featured_cat, i.featured_studio, i.banner, i.banner_line, i.date_start, i.date_end, i.auction_mode,i.quantity
    FROM items i, bids b
   WHERE i.user_id = #session.user_id#
AND i.itemnum=b.itemnum

     AND (i.status = 0
          OR i.date_end < #TIMENOW#)
and b.winner=1
 order by i.title ASC
 </cfquery>


 
         <cfset item_count = 0>
         <cfloop query="getsold_results" >
        
          <!--- increment item_count --->
          <cfset item_count = IncrementValue(item_count)>
        
          <!--- get bids --->
          <cfquery username="#db_username#" password="#db_password#" name="Countbids" datasource="#DATASOURCE#">
              SELECT COUNT(itemnum) AS total
                FROM bids
               WHERE itemnum = #itemnum#
          </cfquery>
        
          <!--- get highest bid --->
          <cfquery username="#db_username#" password="#db_password#" name="HighestBid" datasource="#DATASOURCE#">
              SELECT MAX(bid) AS price
                FROM bids
               WHERE itemnum = #itemnum#
          </cfquery>
          
    		  <!--- get lowest bid --->
          <cfquery username="#db_username#" password="#db_password#" name="LowestBid" datasource="#DATASOURCE#">
              SELECT MIN(bid) AS price
                FROM bids
               WHERE itemnum = #itemnum#
          </cfquery>
   




  <cfquery name="getBidder" datasource="#DATASOURCE#">
    select  b.user_id,U.user_id,U.nickname,U.email
	from bids B,users U
	where b.bid =  <cfif #highestbid.recordcount# neq 0 and #highestbid.price#  neq ""  >#HighestBid.price#<cfelseif #lowestbid.recordcount# neq 0 and #lowestbid.price#  neq "">#lowestbid.price#</cfif>
	and   b.itemnum = #itemnum#
and b.user_id=u.user_id

</cfquery>









 <cfquery username="#db_username#" password="#db_password#" name="insert1" datasource="#DATASOURCE#">
insert into stored(user_id <cfif #getbidder.recordcount#>,user_id_from</cfif>,date_placed,itemnum,remote_ip,seller,date_end) values(#session.user_id# <cfif #getbidder.recordcount#>,#getbidder.user_Id#</cfif>,#timenow#,#itemnum#,'#CGI.REMOTE_ADDR#',1,#createodbcdatetime(date_end)#)
    
 </cfquery>

</cfloop>


 <cfquery username="#db_username#" password="#db_password#" name="getinfo" datasource="#DATASOURCE#">
select * from stored where user_id=#session.user_id# 

order by date_end DESC
    
 </cfquery>

<html>
 <head>
  <title>Leave Feedback</title>
  <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
 </head>

 <cfinclude template="../includes/bodytag.html">
<cfinclude template="../includes/menu_bar.cfm">
<cfif #getinfo.recordcount#>

<!--- The main table --->
  <div align="center">
   <table border=0 cellspacing=0 cellpadding=2 width=800>
        <tr>
          <td>
            <font size=4>
              <b>Leave Feedback for a User</b>
            </font>


</td>
</tr>

        <tr>
          <td>

            <hr width=100% size=1 color=#heading_color#>


</td>
</tr>

</table>
<cfloop query="getinfo">
<cfif #getinfo.buyer# eq 1>
 <cfquery username="#db_username#" password="#db_password#" name="getseller" datasource="#DATASOURCE#">
select nickname,email from users where user_id=#user_id_from# 
    
 </cfquery>
</cfif>
<cfif #getinfo.seller# eq 1>

 <cfquery username="#db_username#" password="#db_password#" name="getbuyer" datasource="#DATASOURCE#">
select nickname,email from users where user_id=#user_id_from# 
    
 </cfquery>

</cfif>


 <cfquery username="#db_username#" password="#db_password#" name="gettitle" datasource="#DATASOURCE#">
select title from items where itemnum=#itemnum#
    
 </cfquery>

<cfquery username="#db_username#" password="#db_password#" name="feedback" datasource="#DATASOURCE#">
select comment from feedback

<cfif #getinfo.seller# eq 1>
   WHERE itemnum = #itemnum# and user_id_from=#session.user_id# 
</cfif>

<cfif #getinfo.buyer# eq 1>

where  itemnum = #itemnum# and user_id=#user_id_from#

</cfif>    
 </cfquery> 
 
 <html>
 <head>
  <title>Leave Feedback</title>
  <link rel=stylesheet href="<cfoutput>#VAROOT#</cfoutput>/includes/stylesheet.css" type="text/css">
 </head>

 <cfinclude template="../includes/bodytag.html">
<cfinclude template="../includes/menu_bar.cfm">
 

<cfif #feedback.recordcount# eq 0>

      <form name="addFeedback" action="../feedback/leavefeedback3.cfm"
method="POST">
      <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td>

            <hr width=100% size=1 color=#heading_color#>

<!---
            <cfif not chkSubmit>
              <cfif chkSelf>
                <cfoutput>#hlightStart#<b>INVALID:</b> You may not place feedback about yourself.#hlightEnd#</cfoutput><br>
              <cfelseif chkSecond>

                <cfoutput><font color=red size=2><b>INVALID:</b> You already left a feedback to this user.</font></cfoutput><br>
              <cfelse>

                <cfoutput>#hlightStart#<b>INCOMPLETE:</b> Please verify that the highlighted items are correct.#hlightEnd#</cfoutput><br>
              </cfif>
              <br>
            </cfif>

--->
          </td>
        </tr>
      </table>
    


        <table border=0 cellspacing=2 cellpadding=0 noshade width=800>
          <tr>
          


            <td>

<!---              <input type=hidden name="user_id_from" value=" #user_id_from#" > --->

<font color=blue size=2><b><cfif #getinfo.buyer# eq 1>Seller<cfelse>Buyer</cfif>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <cfif #getinfo.buyer# eq 1> <a href="#varoot#/messaging">#getseller.nickname#</a>&nbsp;&nbsp;&nbsp;&nbsp;(<a href="mailto:#getseller.email#"> #getseller.email#</a>) &nbsp;&nbsp;&nbsp;&nbsp;<!---(<a href="#varoot#/messaging">#user_id_from#</a>)---><cfelse> <a href="#varoot#/messaging">#getbuyer.nickname#</a>&nbsp;&nbsp;(<a href="mailto:#getbuyer.email#">#getbuyer.email#</a>)&nbsp;&nbsp;<!---(<a href="#varoot#/messaging">#user_id_from#</a>)---></cfif></b></font>
            </td>
            <td>

              <input type=hidden name="password" value="#session.password#" size=20>
            </td>
          </tr>


<tr>
<td>
&nbsp;
</td>
</tr>
<tr>
<td>
<font color=blue size=2><b>
Item:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="#varoot#/listings/details/index.cfm?itemnum=#itemnum#">#gettitle.title#</a>&nbsp;&nbsp;(<a href="#varoot#/listings/details/index.cfm?itemnum=#itemnum#">#itemnum#</a>)</b></font>
</td>
</tr>

          <tr>
            <td>
              <input type=hidden name="buyer" value="#getinfo.buyer#">
              <input type=hidden name="seller" value="#getinfo.seller#">
<cfif #getinfo.seller# eq 1>

              <input type=hidden name="user_id_from" value="#session.user_id#" >

  <input type=hidden name="user_id" value="#user_id_from#" >

</cfif>


<cfif #getinfo.buyer# eq 1>

              <input type=hidden name="user_id" value="#user_id_from#" >

       <input type=hidden name="user_id_from" value="#session.user_id#" > 
</cfif>


            </td>


            <td>
              <input type=hidden name="itemnum" value="#itemnum#" size=20>
            </td>
          </tr>
        </table>
      
        <br>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
<tr>
<td>
<font color=blue size=2><b>Rating:</b></font>

</td>
</tr>


<tr>
<td>
&nbsp;

</td>
</tr>
          <tr>
            <td width=25></td>
            <td width=230 valign=top>
             <b>Tone of your comment:</b>


              <br>
              &nbsp;&nbsp;<input type=radio name="tone" value="1">  Positive<br>
              &nbsp;&nbsp;<input type=radio name="tone" value="0" > Neutral<br>
              &nbsp;&nbsp;<input type=radio name="tone" value="-1"> Negative<br>
            </td>
            
        <td width=385> 
          <div align="left">
            <table border=0 cellspacing=0 cellpadding=2 noshade width=377 height="146">
              <tr bgcolor=000080> 
                <td align=center bgcolor="B90C28"> 
                  <div align="center"><font color=ffffff face="Arial" size=2> 
                    <b><font size="3">You are responsible for your own words. 
                    </font></b></font> </div>
                </td>
              </tr>
              <tr bgcolor=d3d3d3> 
                <td bgcolor="FFFFCC"> 
                  <div align="left"><font size=2> Your comment will include your 
                    user name and the date which you left your remark. We cannot 
                    take responsibility for the comments you post here, and you 
                    should be careful about making comments that could be libelous 
                    or slanderous. To be safe, make only factual, emotionless 
                    comments. Contact your attorney if you have any doubts. Please 
                    try to resolve any disputes with the other party before publically 
                    declaring a complaint. </font> </div>
                </td>
              </tr>
            </table>
          </div>
        </td>
          </tr>
        </table>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
          <tr>
            <td>
              (80 characters max.)<br>
              <input type=text name="comment" value="" size=75 maxlength=80><br>
              <br>
              <font size=2>
                <b>NOTE:</b> <font color="red">Only successful buyers and sellers of this item may leave feedback. Each new feedback must be referenced to a seperate item number.  If you have already 
                left feedback in reference to this <i>item number</i> you can <a href="#VAROOT#/">exit</a> 
                the feedback section here.</font><br>
              </font>
              <br>
             
              <input type=submit name="leave_comment" value="Leave Comment"> 
              <input type=reset value="Reset Form"><br>
              <br>
              <b>Resolving disputes before leaving negative feedback.</b><br>
              As the old saying goes... once you've said something you can't take it back. Once a negative comment 
              has been posted, the damage has already been 
              done. For this reason we encourage all members to contact the person in question 
              directly before leaving negative feedback about them.
            </td>
          </tr>
        </table>

      <br>

      </form>

<cfelse>


</cfif>
</cfloop>

<cfelse><center><font color=red size=2> You don't have any items left to leave feedback.</font></center>
</cfif>
<br>
<br>
<br>



   


<table width=800>
<tr>
<td>
<div align="center">

 <cfinclude template="nav.cfm">
</div>
      </td></tr></table></div>
	  <div align="center">
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