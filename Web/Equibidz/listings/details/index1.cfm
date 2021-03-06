
<!---
  index.cfm
  auction details...
  displays auction details using given item id number (URL)...
--->


<cfsetting enablecfoutputonly="Yes">


<cfparam name="itemnum" default="0">
<cfparam name="img_width" default="500">
<cfparam name="width2" default="124">
<cfparam name="width3" default="124">
<cfparam name="width4" default="124">
<cfparam name="width5" default="124">
<cfparam name="height5" default="110">
<cfparam name="height4" default="110">
<cfparam name="height3" default="110">
<cfparam name="height2" default="110">
<cfif isnumeric(itemnum) eq false>
	<cfset itemnum = 0>
</cfif>
<!--- include globals --->
  <cfinclude template="../../includes/app_globals.cfm">
<cftry>
  
  
  <!--- define TIMENOW --->
  <cfmodule template="../../functions/timenow.cfm">
  
  <cfcatch>
    <cflocation url="http://#CGI.SERVER_NAME##VAROOT#/includes/404notfound.cfm">
  </cfcatch>
</cftry>

<CFSET BROWSER = CGI.HTTP_USER_AGENT>
<cfset MSexplorer = find("MSIE",browser)>


<!--- define if item number valid & retrieve info --->
<cftry>
  <!--- get item's info --->
  <cfquery name="get_ItemInfo" datasource="#DATASOURCE#">

    SELECT 
	itemnum,
	status,
	minimum_bid,
	maximum_bid,
	user_id,
	category1,
	auction_type,
	reserve_bid,
	date_end,
	date_start,
	private,
	pay_morder_ccheck,
	pay_cod,
	pay_see_desc,
	pay_pcheck,
	pay_ol_escrow,
	pay_other,
	pay_visa_mc,
	pay_am_express,
	pay_discover,
	ship_sell_pays,
	ship_buy_pays_act,
	ship_see_desc,
	ship_buy_pays_fxd,
	ship_international,
	picture,
	picture1,
	picture2,
	picture3,
	picture4,
	sound,
	studio,
	featured_studio,
	picture_studio,
	sound_studio,
	increment,
	increment_valu,
	title,
	banner,
	banner_line,
	quantity,
	location,
	country,
	auction_mode,
	hide,
<!---    inspector, --->
	buynow_price,		
	buynow,hit_counter,quantity
    FROM items
    WHERE itemnum = #itemnum#

  </cfquery>

  <cfquery name="get_Itemdesc" datasource="#DATASOURCE#">

    SELECT 
	description
    FROM items
    WHERE itemnum = #itemnum#

  </cfquery>
  
  <!--- define found/not found --->
  <cfset isvalid = IIf(get_ItemInfo.RecordCount, DE("TRUE"), DE("FALSE"))>
  
  <cfcatch>
    <cfset isvalid = "FALSE">
  </cfcatch>
</cftry>


<cfparam name="cookie.auction_cntr" default="0">
<cfif ListContains(cookie.auction_cntr, itemnum) is 0>
	<cfset hit_cnts = #IncrementValue(get_ItemInfo.hit_counter)#>
	<cfquery username="#db_username#" password="#db_password#" name="update_hitcount" datasource="#DATASOURCE#">
		UPDATE items
		SET hit_counter = #hit_cnts#
		WHERE itemnum = #itemnum#
	</cfquery>
	<cfset item_cnt_list = listappend(cookie.auction_cntr, itemnum)>
	<cfcookie name="auction_cntr" value="#item_cnt_list#" expires="1">
<cfelse>
	<cfset hit_cnts = get_ItemInfo.hit_counter>
</cfif>



<cfif mode_switch is "dual">
  <cfset session.auction_mode = get_ItemInfo.auction_mode>
  <cfset auction_mode = session.auction_mode>
<cfelse>
  <cfset session.auction_mode = auction_mode>
</cfif>


 
 
<!--Regular auctions -->
<cfif #session.auction_mode# is 0>


<!--- if valid item get rest of info --->
<cfif isvalid>
  <!--- enable Session state management --->
  <cfset mins_until_timeout = 60>
  <cfapplication name="UserManagement" sessionmanagement="Yes" sessiontimeout="#CreateTimeSpan(0, 0, mins_until_timeout, 0)#">
  
  <!--- get currency type --->
  <cfquery name="getCurrency" datasource="#DATASOURCE#">
      SELECT pair AS type
        FROM defaults
       WHERE name = 'site_currency'
  </cfquery>
  
  <!--- def currency name --->
  <cfmodule template="../../functions/cf_currencies.cfm"
    mode="CODECONVERT"
    code="#Trim(getCurrency.type)#"
    return="currencyName">
  
  <!--- def if auction complete --->
  <cfmodule template="../../functions/auction_complete.cfm"
    iItemnum = "#itemnum#">
    
  <cftry>
    <!--- get category name of item --->
    <cfquery name="get_CategoryInfo" datasource="#DATASOURCE#">
        SELECT name,category
          FROM categories
         WHERE category = #get_ItemInfo.category1#
    </cfquery>
    
    <cfset category_name = Trim(get_CategoryInfo.name)>
    
    <cfcatch>
      <cfset category_name = "Not Available">
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get current high bid --->
    <cfquery name="get_HighBid" datasource="#DATASOURCE#">
        SELECT MAX(bid) AS highest
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#

    </cfquery>
    
    <cfif not get_HighBid.RecordCount>
      <cfthrow>
    </cfif>
    
    <cfset current_bid = get_HighBid.highest>
    
    <cfcatch>
      <cfset current_bid = get_ItemInfo.minimum_bid>
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get seller's info --->
    <cfquery name="get_SellerInfo" datasource="#DATASOURCE#">
        SELECT nickname, email,mypage,membership_status
          FROM users
         WHERE user_id = #get_ItemInfo.user_id#
    </cfquery>
    
    <cfset seller_nickname = Trim(get_SellerInfo.nickname)>
    <cfset seller_email = Trim(get_SellerInfo.email)>
    
    <cfcatch>
      <cfset seller_nickname = "Not Available">
      <cfset seller_email = "Not Available">
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get parents of this category --->
    <cfmodule template="../../functions/parentlookup.cfm"
      CATEGORY="#get_ItemInfo.category1#"
      DATASOURCE="#DATASOURCE#"
      RETURN="parents_array">
    
    <cfcatch>
      <cfset parents_array = ArrayNew(2)>
    </cfcatch>
  </cftry>
  
  <cftry>
  	<!--- get number of buynow --->
    <cfquery username="#db_username#" password="#db_password#" name="get_buynow_cnt" datasource="#DATASOURCE#">
        SELECT COUNT(buynow) AS buynow_cnt
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#
		 AND buynow = 1
    </cfquery>


  <cfquery username="#db_username#" password="#db_password#" name="bid_find" datasource="#DATASOURCE#">
        SELECT max(bid) as total
          FROM proxy_bids
         WHERE itemnum = #get_ItemInfo.itemnum#
		 
    </cfquery>

    <!--- get current bid, number of bids, define reserve met --->
    <cfquery username="#db_username#" password="#db_password#" name="get_HighBid" datasource="#DATASOURCE#">
        SELECT MAX(bid) AS highest, COUNT(bid) AS bidcount
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#
		 AND buynow = 0
    </cfquery>
    
    <cfset bid_currently = IIf(get_HighBid.bidcount, "get_HighBid.highest", "get_ItemInfo.minimum_bid")>
    <cfset bid_count = get_HighBid.bidcount>
    
    <cfif get_ItemInfo.auction_type IS "V">
      <cfquery name="getSecondBid" datasource="#DATASOURCE#" maxrows=2>
          SELECT bid
            FROM bids
           WHERE itemnum = #get_ItemInfo.itemnum#
           ORDER BY bid DESC
      </cfquery>
      
      <cfloop query="getSecondBid">
        <cfset secondBidder = getSecondBid.bid>
      </cfloop>
      
      <!--- if bids on item --->
      <cfif getSecondBid.RecordCount>
        
        <cfset reserve_met = IIf(secondBidder LT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
      <cfelse>
        
        <cfset reserve_met = IIf(bid_currently LT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
      </cfif>
      
    <cfelse>
      <cfset reserve_met = IIf(bid_currently LT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
    </cfif>
    
    <cfcatch>
      <cfset bid_currently = "Not Available">
      <cfset reserve_met = "not available">
      <cfset bid_count = "Not Available">
    </cfcatch>
  </cftry>
  
  <!--- define time left --->
  <cfif hAuctionComplete.bComplete>
    <cfset timeleft = '<font color=ff0000>COMPLETED</font>'>
  <cfelse>
    <cfset timeleft = hAuctionComplete.tsDateEnd - TIMENOW>
    <cfif timeleft GT 1>
      <cfset daysleft = IIf(Int(timeleft) LT 0, DE("0"), "Int(timeleft)")>
      <cfset hrsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('h', timeleft)")>
      <cfset minsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('n', timeleft)")>
      <cfset dayslabel = IIf(daysleft IS 1, DE("day"), DE("days"))>
      <cfset hrslabel = IIf(hrsleft IS 1, DE("hour"), DE("hours"))>
      <cfset timeleft = daysleft & " " & dayslabel & ", " & hrsleft & " " & hrslabel & " +">
    <cfelse>
      <cfset hrsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('h', timeleft)")>
      <cfset minsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('n', timeleft)")>
      <cfset hrslabel = IIf(hrsleft IS 1, DE("hour"), DE("hours"))>
      <cfset minslabel = IIf(minsleft IS 1, DE("min"), DE("mins"))>
      <cfset timeleft = hrsleft & " " & hrslabel & ", " & minsleft & " " & minslabel & " +">
    </cfif>
  </cfif>
  
  <!--- define started date format --->
  <cfset started = DateFormat(get_ItemInfo.date_start, "mm/dd/yy") & " " & TimeFormat(get_ItemInfo.date_start, "HH:mm:ss")>
  
  <!--- define ends date format --->
  <cfset ends = DateFormat(hAuctionComplete.tsDateEnd, "mm/dd/yy") & " " & TimeFormat(hAuctionComplete.tsDateEnd, "HH:mm:ss")>
  
  <!--- define seller's feedback rating --->
  <cftry>
    <cfquery name="get_SellerFeedback" datasource="#DATASOURCE#">
        SELECT SUM(rating) AS ratinglevel, COUNT(rating) AS totalfeed
          FROM feedback
         WHERE user_id = #get_ItemInfo.user_id#
    </cfquery>
    
    <cfif get_SellerFeedback.totalfeed>
      <cfset ratingSeller = Round(get_SellerFeedback.ratinglevel)>
    <cfelse>
      <cfset ratingSeller = 0>
    </cfif>
    
    <cfcatch>
      <cfset ratingSeller = "not available">
    </cfcatch>
  </cftry>
  
  <!--- define "ask seller question" link value --->
  <cfif get_ItemInfo.private>
    <cfset questionLinkSell = "#VAROOT#/messaging/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">
  <cfelse>
    <cfset questionLinkSell = "mailto:" & seller_email>
  </cfif>
  
  <!--- get high bidder info --->
  <cftry> 
    <cfquery name="getHighBidder" datasource="#DATASOURCE#" maxrows="1">
        SELECT user_id,buynow
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#
	<!---	 AND buynow = 0 --->
         ORDER BY bid DESC
    </cfquery>
    
    <cfquery name="getBidderInfo" datasource="#DATASOURCE#">
        SELECT nickname, email,mypage,membership_status
          FROM users
         WHERE user_id = #getHighBidder.user_id#
    </cfquery>
    
    <cfquery name="getBidderRating" datasource="#DATASOURCE#">
        SELECT SUM(rating) AS ratinglevel, COUNT(rating) AS totalfeed
          FROM feedback
         WHERE user_id = #getHighBidder.user_id#
    </cfquery>
    
<cfquery name="getdisplay" datasource="#DATASOURCE#">
        SELECT bid, buynow
          FROM bids
         WHERE user_id = #getHighBidder.user_id#
    </cfquery>
    <cfif getBidderInfo.RecordCount  >
      <cfset bidderNickname = Trim(getBidderInfo.nickname)>
      <cfset bidderEmail = Trim(getBidderInfo.email)>
      <cfset bidderId = getHighBidder.user_id>
<!---   <cfelseif gethighbidder.buynow  eq 1>
          <cfset bidderNickname = Trim(getBidderInfo.nickname)>
      <cfset bidderEmail = Trim(getBidderInfo.email)>
      <cfset bidderId = getHighBidder.user_id>
--->

<cfelse>
  <cfset bidderNickname = "Not Available">
      <cfset bidderEmail = "Not Available">
    </cfif>
    
    <cfif getBidderRating.totalfeed>
      <cfset ratingBidder = Round(getBidderRating.ratinglevel)>
    <cfelse>
      <cfset ratingBidder = 0>
    </cfif>
    
  <cfcatch>
      <cfset bidderNickname = "Not Available">
      <cfset bidderEmail = "Not Available">
      <cfset ratingBidder = "not available">
      <cfset bidderId = "not available">
    </cfcatch>
  </cftry>

  <!--- define "mailto" link value --->
  <cfif get_ItemInfo.private>
    <cfset questionLinkBid = "#VAROOT#/messaging/index.cfm?user_id=" & bidderId>
  <cfelse>
    <cfset questionLinkBid = "mailto:" & bidderEmail>
  </cfif>
  
  <!--- define payment options --->
  <cfmodule template="../../functions/options_list.cfm"
    mode="PAYMENT"
    morder_ccheck="#get_ItemInfo.pay_morder_ccheck#"
    cod="#get_ItemInfo.pay_cod#"
    see_desc="#get_ItemInfo.pay_see_desc#"
    pcheck="#get_ItemInfo.pay_pcheck#"
    ol_escrow="#get_ItemInfo.pay_ol_escrow#"
    other="#get_ItemInfo.pay_other#"
    visa_mc="#get_ItemInfo.pay_visa_mc#"
    am_express="#get_ItemInfo.pay_am_express#"
    discover="#get_ItemInfo.pay_discover#">
  
  <!--- define shipping options --->
  <cfmodule template="../../functions/options_list.cfm"
    mode="SHIPPING"
    sell_pays="#get_ItemInfo.ship_sell_pays#"
    buy_pays_act="#get_ItemInfo.ship_buy_pays_act#"
    see_desc="#get_ItemInfo.ship_see_desc#"
    buy_pays_fxd="#get_ItemInfo.ship_buy_pays_fxd#"
    international="#get_ItemInfo.ship_international#">
  
  <!--- define pictureURL --->
  <cfif Right(get_ItemInfo.picture, 4) IS ".gif"
   OR Right(get_ItemInfo.picture, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture, 4) IS ".png">
    <cfset isImage = "TRUE">
    <cfset pictureURL = Trim(get_ItemInfo.picture)>
  <cfelse>
    <cfset isImage = "FALSE">
  </cfif>
  
  <!--- define picture1URL --->
  <cfif get_ItemInfo.picture1 neq ""
   and (Right(get_ItemInfo.picture1, 4) IS ".gif"
   OR Right(get_ItemInfo.picture1, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture1, 4) IS ".png")>
    <cfset isImage1 = "TRUE">
    <cfset picture1URL = Trim(get_ItemInfo.picture1)>
  <cfelse>
  <cfset isImage1 = "FALSE"> 
  </cfif>
  <!--- define picture2URL --->
  <cfif get_ItemInfo.picture2 neq "" 
   and (Right(get_ItemInfo.picture2, 4) IS ".gif"
   OR Right(get_ItemInfo.picture2, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture2, 4) IS ".png")>
    <cfset isImage2 = "TRUE">
    <cfset picture2URL = Trim(get_ItemInfo.picture2)>
  <cfelse>
     <cfset isImage2 = "FALSE">  
  </cfif>
  
  <!--- define picture3URL --->
  <cfif get_ItemInfo.picture3 neq "" 
   and (Right(get_ItemInfo.picture3, 4) IS ".gif"
   OR Right(get_ItemInfo.picture3, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture3, 4) IS ".png")>
    <cfset isImage3 = "TRUE">
    <cfset picture3URL = Trim(get_ItemInfo.picture3)>
  <cfelse>
     <cfset isImage3 = "FALSE">  
  </cfif>
  
  <!--- define picture4URL --->
  <cfif get_ItemInfo.picture4 neq "" 
   and (Right(get_ItemInfo.picture4, 4) IS ".gif"
   OR Right(get_ItemInfo.picture4, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture4, 4) IS ".png")>
    <cfset isImage4 = "TRUE">
    <cfset picture4URL = Trim(get_ItemInfo.picture4)>
  <cfelse>
      <cfset isImage4 = "FALSE"> 
  </cfif>
  <!--- define soundURL --->
  <cfif Right(get_ItemInfo.sound, 4) IS ".wav" 
   OR Right(get_ItemInfo.sound, 3) IS ".au" 
   OR Right(get_ItemInfo.sound, 3) IS ".ra" 
   OR Right(get_ItemInfo.sound, 4) IS ".mp3" 
   OR Right(get_ItemInfo.sound, 4) IS ".mid">
    <cfset isSound = "TRUE">
    <cfset soundURL = Trim(get_ItemInfo.sound)>
  <cfelse>
    <cfset isSound = "FALSE">
  </cfif>
  
  <!--- define studioPictureURL --->
  <cfif get_ItemInfo.studio>
    <cfif Right(get_ItemInfo.picture_studio, 4) IS ".gif" 
      OR Right(get_ItemInfo.picture_studio, 4) IS ".jpg"
      OR Right(get_ItemInfo.picture_studio, 4) IS ".png">
      <cfset isStudioImage = "TRUE">
      <cfset studioPictureURL = Trim(get_ItemInfo.picture_studio)>
    <cfelse>
      <cfset isStudioImage = "FALSE">
    </cfif>
  <cfelse>
    <cfset isStudioImage = "FALSE">
  </cfif>
  
  <!--- define studioSoundURL --->
  <cfif get_ItemInfo.studio>
    <cfif Right(get_ItemInfo.sound_studio, 4) IS ".wav" 
      OR Right(get_ItemInfo.sound_studio, 3) IS ".au" 
      OR Right(get_ItemInfo.sound_studio, 3) IS ".ra" 
      OR Right(get_ItemInfo.sound_studio, 4) IS ".mp3" 
      OR Right(get_ItemInfo.sound_studio, 4) IS ".mid">
      <cfset isStudioSound = "TRUE">
      <cfset studioSoundURL = Trim(get_ItemInfo.sound_studio)>
    <cfelse>
      <cfset isStudioSound = "FALSE">
    </cfif>
  <cfelse>
    <cfset isStudioSound = "FALSE">
  </cfif>
  
  <!--- bidIncrement & minimumBid --->
  <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
    <cfset bidIncrement = IIf(get_ItemInfo.increment, "get_ItemInfo.increment_valu", "0.01")>
    <cfset minimumBid = numberFormat(Evaluate(bid_currently + bidIncrement),numbermask)>
<cfif get_highbid.bidcount LT 1>
    <cfset minimumBid = numberFormat(bid_currently,numbermask)>
	</CFIF>
    <cfset bidIncrement = numberFormat(bidIncrement,numbermask)>
  <cfelse>
  <cfset bidIncrement = IIf(get_ItemInfo.increment, "get_ItemInfo.increment_valu", "get_ItemInfo.increment_valu")>
    <cfmodule template="../../functions/dutch_bidding.cfm"
		itemnum="#get_itemInfo.itemnum#"
		quantity="#get_itemInfo.quantity#"
		minimum_bid = "#get_itemInfo.minimum_bid#">
    <cfset minimumBid = numberformat(minimumBid,numbermask)>
  </cfif>
  <cfset bid_currently = numberFormat(bid_currently,numbermask)>
  
  <!--- define userNickname if Session available --->
  <cftry>
    <cfif IsDefined("Session.nickname")>
      <cfset userNickname = Session.nickname>
    <cfelse>
      <cfset userNickname = "">
    </cfif>
    
    <cfcatch>
      <cfset userNickname = "">
    </cfcatch>
  </cftry>
  
  <!--- get default bid type --->
  <cftry>
    <cfquery name="getDefBidType" datasource="#DATASOURCE#">
        SELECT pair AS def_bidding
          FROM defaults
         WHERE name = 'def_bidding'
    </cfquery>
    
    <cfset defBidType = getDefBidType.def_bidding>
    
    <cfcatch>
      <cfset defBidType = "REGULAR">
    </cfcatch>
  </cftry>
  
  <!--- get enable_ssl --->
  <cftry>
    <cfquery name="getSSL" datasource="#DATASOURCE#">
        SELECT pair AS enable_ssl
          FROM defaults
         WHERE name = 'enable_ssl'
    </cfquery>
    
    <cfset enableSSL = getSSL.enable_ssl>
    
    <cfcatch>
      <cfset enableSSL = "FALSE">
    </cfcatch>
  </cftry>
</cfif>

<!--- get bool iescrow enabled --->
<cfmodule template="../../functions/iescrow.cfm"
  sOpt="ChkStatus">

<!--- if iescrow enabled, get current vals --->
<cfif hIEscrow.bEnabled>
  
  <cfmodule template="../../functions/IEscrowIcons.cfm"
    sOpt="DISP/FRONTPAGE">
</cfif>


<cfmodule template="../../functions/browsercheck.cfm">

<!--- output information --->
<cfsetting enablecfoutputonly="No">

<cfoutput>

<html>
  <head>
    <title><cfif isvalid>Item #get_ItemInfo.itemnum# (#Trim(get_ItemInfo.title)#)<cfelse>Item Not Found</cfif></title>


    <link rel=stylesheet href="#VAROOT#/includes/stylesheet.css" type="text/css">
</cfoutput>

  </head>


<!--- <script language="javascript">

    function showCalc(){
			if (!window.popup){  // has not yet been defined
    	  popup=window.open("../../functions/w_currency1.cfm?bid_currently=<cfoutput>#bid_currently#</cfoutput>","calcWin","height=290,width=360,top=20,left=420");
			  self.focus()
				popup.document.close()
			}else{
				if (!popup.closed){ // has been defined
    	    popup.focus()
				}else{
				  popup=window.open("../../functions/w_currency1.cfm?bid_currently=<cfoutput>#bid_currently#</cfoutput>","calcWin","height=290,width=360,top=20,left=420")
					popup.document.close()
				}
  		}
		}
// duh pop-up window		showCalc()

    </script> --->
<script language="JavaScript">
<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture1URL")> 
  function winOpen1(){
  msgWindow=window.open("large_pic.cfm?Image=1&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif> 
<cfelse>

<cfif isdefined("picture1URL")> 
  function winOpen1() {

   s="../../fullsize_thumbs/<cfoutput>#picture1URL#</cfoutput>"
   detailWin = window.open(s,"title1","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=450,height=450,left=10,top=120,alwaysRaised=yes");
//  detailWin.location.reload(true);

  }

</cfif>
</cfif> 

<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture2URL")>
  function winOpen2(){
  msgWindow=window.open("large_pic.cfm?Image=2&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif>
<cfelse>
  <cfif isdefined("picture2URL")>
  function winOpen2() {
  s="../../fullsize_thumbs0/<cfoutput>#picture2URL#</cfoutput>"
  detailWin = window.open(s,"title2","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 // detailWin.location.reload(true);
  }
  </cfif>
</cfif>

<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture3URL")>
  function winOpen3(){
  msgWindow=window.open("large_pic.cfm?Image=3&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif>
<cfelse>
  <cfif isdefined("picture3URL")>
  function winOpen3() {
  s="../../fullsize_thumbs1/<cfoutput>#picture3URL#</cfoutput>"
  detailWin = window.open(s,"title3","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 // detailWin.location.reload(true);
  }
  </cfif>
</cfif>

<cfif #bc_version# GT 4.5>
 <cfif isdefined("picture4URL")>
 function winOpen4(){
 msgWindow=window.open("large_pic.cfm?Image=4&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        }
 </cfif>
<cfelse>
  <cfif isdefined("picture4URL")>
  function winOpen4() {
  s="../../fullsize_thumbs2/<cfoutput>#picture4URL#</cfoutput>"
  detailWin = window.open(s,"title4","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 //detailWin.location.reload(true);
}
  </cfif>
</cfif> 
</script>

<cfoutput>





 <script language = "javascript">
      function inspector(){
			if (!window.popup){  // has not yet been defined
        if (#MSexplorer# == 0){
      	  popup=window.open("http://#site_address##varoot#/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=250,width=206,top=110,left=520");
      	}else{
        	popup=window.open("http://#site_address##varoot#/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=260,width=206,top=110,left=520");
      	}  
//			  self.focus()
				popup.document.close()
			}else{
				if (!popup.closed){ // has been defined
    	    popup.focus()
				}else{
       if (#MSexplorer# == 0){
    				popup=window.open("http://#site_address##varoot#/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=250,width=206,top=110,left=520");
          }else{
				    popup=window.open("http://#site_address##varoot#/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=260,width=206,top=110,left=520")
          }
					popup.document.close()
				}
  		}
		}
















  </script>  




<!--countdown clock--->

<!---may cause error --->
<!---     <cfinclude template="../../includes/bigtime.cfm"> --->
<body>
<!---emcapsulating table ---> 
<table border=0 cellspacing=0 cellpadding=0 noshade width="800" align="center">
<center>
<cfinclude template="../../includes/bodytag.html">
<cfinclude template="../../includes/menu_bar.cfm">
<cfset Img_width=124>      
<cfset Img_height=110>      
   
      <br>
      <table border=0 cellspacing=0 cellpadding=0 noshade width="800" align="center">
        <tr>
          <td>
            
              
                  <cfif isvalid>
                    <cfif #get_ItemInfo.studio# IS 1 and get_itemInfo.hide IS 0>
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","thumbs\")#>
                      
<cfif fileExists("#thePath##itemnum#.jpg")>
	  <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg"> --->
<cfif img_height is "" or img_width is "">
<table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG width=124 height=110 src="#varoot#/thumbs/#itemnum#.jpg" border=0></a></td></tr></table><br>
<cfelse>
	  <cfif img_height gt img_width>
	  	<cfset width = (Img_width/Img_height) * 124>
	  	<cfset height = (Img_height/Img_width) * width>
	  <cfelse>
	  	<cfset height = (Img_height/Img_width) * 124>
	  	<cfset width = (Img_width/Img_height) * height>
	  </cfif>
     <table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG src=#varoot#/thumbs/#itemnum#.jpg width=#width# height=#height# border="0"></a></td></tr></table>
</cfif>
    <cfelseif fileExists("#thePath##itemnum#.gif")>
	  <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif"> --->
<cfif img_height is "" or img_width is "">
<table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG width=124 height=110 src="#varoot#/thumbs/#itemnum#.gif" border=0></a></td></tr></table><br>
<cfelse>
	  <cfif img_height gt img_width>
	  	<cfset width = (Img_width/Img_height) * 124>
	  	<cfset height = (Img_height/Img_width) * width>
	  <cfelse>
	  	<cfset height = (Img_height/Img_width) * 124>
	  	<cfset width = (Img_width/Img_height) * height>
	  </cfif>
     <table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG src=#varoot#/thumbs/#itemnum#.gif width=#width# height=#height# border="0"></a></td></tr></table>
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>      





<!---<cfif fileExists("#thePath##itemnum#.jpg")>
                        <IMG src="#varoot#/thumbs/#itemnum#.jpg">
                      <cfelseif fileExists("#thePath##itemnum#.gif")>
                        <IMG src="#varoot#/thumbs/#itemnum#.gif">
					  <cfelse>
                        &nbsp;
			       </cfif>--->
                    </cfif>
                  
                  <cfelse>
                    Not Found
                  </cfif>
          </td>
		  <td width="100%">
		  	<table width="100%" bgcolor=#heading_color#><tr><td width="100%" align="center" valign="middle">
		  	<FONT size="4" COLOR=#heading_fcolor#>
				<b>#Trim(get_ItemInfo.title)#</b>
			</font>
			            <hr size=1 color=#heading_color# width=100%>
            <FONT COLOR=white><cfif isvalid><b>Item ## #get_ItemInfo.itemnum#<cfif get_ItemInfo.banner> - #get_ItemInfo.banner_line#</cfif></b></font></cfif>
			</td></tr></table>
		  </td>
        </tr>
      </table>
      
      <cfif not isvalid>
              Item not found... please try another item.
            </center>
          </body>
        </html>
        <cfabort>
      </cfif>
      








     <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td>
            <font size=2>
              <center>
                <br>
                




    <cfsetting enablecfoutputonly="Yes">
                <!--- output parents --->
                <cfloop index="i" from="#ArrayLen(parents_array)#" to="1" step="-1">
                  <cfif i IS ArrayLen(parents_array)>
                    <cfset link = "#VAROOT#/listings/categories/index.cfm">
                  <cfelse>
                    <cfset link = "#VAROOT#/listings/categories/index.cfm?category=#parents_array[i][2]#">
                  </cfif>



                 <a href="#link#"><font color=#heading_color# size=3><b><i>#parents_array[i][1]#</b></i></font></a>: 


                </cfloop>

<a href="#VAROOT#/listings/categories/index.cfm?category=#get_categoryinfo.category#"><font color=#heading_color# size=3><b><i>  #Variables.category_name#:</b></i></font></a>



        <cfsetting enablecfoutputonly="No">
              
 

<br>
<br>
            <font size=1 color=#heading_color#><b>
<i>              Server time :#DateFormat(TIMENOW, "mmm-d-yyyy")#, #TimeFormat(TIMENOW, "HH:mm:sstt")#;&nbsp #TIME_ZONE#
</i></b>            </font>

              </center>
            </font>
          </td>

        </tr>


      </table><br>
	  


      <!-- auction information -->
	  
      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td rowspan=11 valign=top align=left nowrap><!--- width=80 --->
            <font size=2>
              <br>
              <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><img src="#VAROOT#/legends/#get_layout.descriptionicon#" border="0" align="absmiddle">&nbsp;Description</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <br>
              <br>
              <br>
              <br>
              
              <!--- auction is still running, including dynamic bid --->
              <cfif hAuctionComplete.bComplete IS 0>
                <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###BID"><img src="#VAROOT#/legends/#get_layout.bidicon#" border="0" align="absmiddle">&nbsp;Bid</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              </cfif>
              
            </font>
          </td>
          <td width=80 valign=top>
            <font size=2>
              Currently
            </font>
          </td>
          <td width=200 valign=top nowrap>
            <font size=2>
              <b>#bid_currently# #Trim(getCurrency.type)#</b> #reserve_met#
 <a href="http://www.xe.com/pca/launch.cgi?Amount=#bid_currently#&From=#getcurrency.type#&ToSelect=USD"><img src="../../images/small_calc1.gif" border=0 alt="The Currency Converter"></a>

            </font>
          </td>
          <td width=80 valign=top>
            <font size=2>
              First Bid
            </font>



          </td>

          <td width=200 valign=top>
            <font size=2>
              #numberFormat(get_ItemInfo.minimum_bid,numbermask)# #Trim(getCurrency.type)#
            </font>



          </td>
        </tr>
		<cfif #get_iteminfo.buynow# eq 1>
		
			<!--- get bids over buynow price --->
			<!--- <cfquery username="#db_username#" password="#db_password#" name="getbidsoverbuynow" datasource="#DATASOURCE#">
        		SELECT count(bid) as cnt_bidover_buynow_price
          		FROM bids
         		WHERE itemnum = #itemnum#
		 		AND bid > #get_ItemInfo.buynow_price#
    		</cfquery> --->
			
			<!--- check buynow only for English auction --->
			<cfquery username="#db_username#" password="#db_password#" name="cnt_buynow" datasource="#DATASOURCE#">
        		SELECT count(bid) as cnt_buynow
          		FROM bids
         		WHERE itemnum = #itemnum#
		 		AND buynow = 1
    		</cfquery>
<!---		
			  <cfif numberformat(REReplace(minimumBid, "[^0123456789.]", "", "ALL"),'#numbermask#') lte numberformat(get_ItemInfo.buynow_price,'#numbermask#')>

--->

<cfif   get_iteminfo.buynow and #bid_find.recordcount# and #bid_find.total# lt #get_iteminfo.buynow_price# or  (bid_find.recordcount eq 0 )>

<!--- ((get_ItemInfo.auction_type IS "E" or get_ItemInfo.auction_type IS "V") and minimumbid lte get_ItemInfo.buynow_price) or ((get_ItemInfo.auction_type IS "D" or get_ItemInfo.auction_type IS "Y") and  getbidsoverbuynow.cnt_bidover_buynow_price lt get_ItemInfo.quantity) --->
		 <tr>
		 <td width=80 valign=top>
            <font size=2>
              <a href="../../help/bidtypes.cfm##buynow">BuyNow Price</a>
            </font>




          </td>





          <td width=200 valign=top>
            <font size=2>
              <b>#numberFormat(get_ItemInfo.buynow_price,numbermask)# #Trim(getCurrency.type)#</b> <cfif get_ItemInfo.quantity eq 0 and cnt_buynow.cnt_buynow gt 0><b><font color="ff0000">SOLD</font></b></cfif>
            </font>
          </td>
		</tr>
			</cfif>
		</cfif>
        <tr>
          <td valign=top>
            <font size=2>
              Quantity
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#get_ItemInfo.quantity#</b>
            </font>
          </td>
          <td valign=top>
            <font size=2>
              ## of Bids
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#bid_count#</b> (<a href="#VAROOT#/listings/details/bidhistory.cfm?itemnum=#get_ItemInfo.itemnum#">bid history</a>) <cfif get_iteminfo.buynow eq 1 and  cnt_buynow.cnt_buynow gt 0><b>#cnt_buynow.cnt_buynow#</b> (<a href="#VAROOT#/listings/details/buynow_history.cfm?itemnum=#get_ItemInfo.itemnum#">BuyNow</a>)</cfif>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Time Left
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#timeleft#</b>
            </font>
          </td>
          <td valign=top>
            <font size=2>
              Location
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#Trim(get_ItemInfo.location)#</b>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Started
            </font>
          </td>
          <td valign=top>
            <font size=2>
              #started#
            </font>
          </td>
          <td valign=top>
            <font size=2>
            Country
            </font>
          </td>
          <td valign=top>
            <font size=2>
            <b>#Trim(get_ItemInfo.country)#</b>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Ends
            </font>
          </td>
          <td valign=top>
            <font size=2>
              #ends#
            </font>
          </td>
          <td colspan=2 valign=top>
            <font size=2>
              (<a href="#VAROOT#/listings/details/emailauction.cfm?itemnum=#get_ItemInfo.itemnum#">mail this auction to a friend</a>)
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Seller
            </font>
          </td>
          <td valign=top>
            <font size=2>




							<cfif ratingSeller LTE 9><cfset ratinglegend=#get_layout.legend1#>
							<cfelseif ratingSeller LTE 49><cfset ratinglegend=#get_layout.legend2#>
							<cfelseif ratingSeller LTE 99><cfset ratinglegend=#get_layout.legend3#>
							<cfelseif ratingSeller LTE 499><cfset ratinglegend=#get_layout.legend4#>
							<cfelseif ratingSeller LTE 999><cfset ratinglegend=#get_layout.legend5#>
							<cfelseif ratingSeller LTE 4999><cfset ratinglegend=#get_layout.legend6#>
							<cfelseif ratingSeller LTE 9999><cfset ratinglegend=#get_layout.legend7#>
							<cfelseif ratingSeller LTE 24999><cfset ratinglegend=#get_layout.legend8#>
							<cfelseif ratingSeller LTE 49999><cfset ratinglegend=#get_layout.legend9#>
							<cfelseif ratingSeller LTE 99999><cfset ratinglegend=#get_layout.legend10#>
							<cfelse><cfset ratinglegend=#get_layout.legend11#>
							</cfif>
	







							<cfif ratingbidder LTE 9><cfset ratinglegend=#get_layout.legend1#>
							<cfelseif ratingbidder LTE 49><cfset ratinglegend=#get_layout.legend2#>
							<cfelseif ratingbidder LTE 99><cfset ratinglegend=#get_layout.legend3#>
							<cfelseif ratingbidder LTE 499><cfset ratinglegend=#get_layout.legend4#>
							<cfelseif ratingbidder LTE 999><cfset ratinglegend=#get_layout.legend5#>
							<cfelseif ratingbidder LTE 4999><cfset ratinglegend=#get_layout.legend6#>
							<cfelseif ratingbidder LTE 9999><cfset ratinglegend=#get_layout.legend7#>
							<cfelseif ratingbidder LTE 24999><cfset ratinglegend=#get_layout.legend8#>
							<cfelseif ratingbidder LTE 49999><cfset ratinglegend=#get_layout.legend9#>
							<cfelseif ratingbidder LTE 99999><cfset ratinglegend=#get_layout.legend10#>
							<cfelse><cfset ratingbidder=#get_layout.legend11#>
							</cfif>
	

	              <b><a href="#questionLinkSell#">#seller_nickname#</a>
									<b>(</b>
									<b><a href="#VAROOT#/feedback/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">#ratingSeller#</a></b>
									<b><a href="#VAROOT#/feedback/legend.cfm">





							<cfif ratingSeller LTE 9>
<img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend1#">
							<cfelseif ratingSeller LTE 49><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend2#">
							<cfelseif ratingSeller LTE 99><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend3#">
							<cfelseif ratingSeller LTE 499><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend4#">
							<cfelseif ratingSeller LTE 999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend5#">
							<cfelseif ratingSeller LTE 4999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend6#">
							<cfelseif ratingSeller LTE 9999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend7#">
							<cfelseif ratingSeller LTE 24999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend8#">
							<cfelseif ratingSeller LTE 49999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend9#">
							<cfelseif ratingSeller LTE 99999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend10#">
							<cfelse><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend11#">
							</cfif>
	

</a></b>
									<b>)</b>
									<cfif get_SellerInfo.mypage neq "">
										<a href="../../personal/mypage.cfm?nickname=#get_SellerInfo.nickname#" target="_blank"><img src="/legends/#get_layout.aboutmeicon#"  border="0" align="absbotton"></a>
									</cfif>

<cfif #get_SellerInfo.membership_status# eq 1>
										<a href="../../help/about_membership.cfm" target="_blank"><img src="/legends/#get_layout.membershipicon#"  border="0" align="absbotton"></a>
									</cfif>

          </td>		 
			  <td colspan=2 valign=top>
		  	<font size=2>
              (<a href="#VAROOT#/personal/add_watchlist.cfm?itemnum=#get_ItemInfo.itemnum#">Watch this item</a>)
            </font>
		  </td>


        </tr>
        <tr>
          <td></td>
          <td colspan=4 valign=top>
            <font size=2>
              (<a href="#VAROOT#/feedback/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">view feedback on seller</a>) (<a href="#VAROOT#/search/search_results.cfm?search_type=seller_search&search_text=#get_ItemInfo.user_id#&search_name=Search+by+Seller&auction_mode=#auction_mode#&order_by=date_end&sort_by=DESC">view other auctions by seller</a>) (<a href="#questionLinkSell#">ask seller a question</a>)



            </font>




          <cfif #get_ItemInfo.inspector# is not "">
          <font size=2>
            <a href="javascript:inspector()">(Check this item with The Inspector)</a>&nbsp;<img src="../../images/loupe.gif" height=16 width=16 border=0>
          <!--- duh  pop-up window  <script language="javascript">inspector()</script>
--->

          </font>            
          </cfif>






</td>
        </tr>






<!---

  <td colspan=2 valign=right>
          <cfif #get_ItemInfo.inspector# is not "">
          <font size=2>
            <a href="javascript:inspector()">(Check this item with The Inspector)</a>&nbsp;<img src="../../images/loupe.gif" height=16 width=16 border=0>
            <script language="javascript">inspector()</script>
          </font>            
          </cfif>
          </td>




--->
        <tr>
          <td valign=top>
            <font size=2>
              High bid
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
            <cfif bidderNickname IS NOT "Not Available" ><b><a href="#questionLinkBid#">#bidderNickname#</a> (<a href="#VAROOT#/feedback/index.cfm?user_id=#bidderId#">#ratingBidder#</a>
<b><a href="#VAROOT#/feedback/legend.cfm">							<cfif ratingbidder LTE 9>
<img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend1#">
							<cfelseif ratingbidder LTE 49><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend2#">
							<cfelseif ratingbidder LTE 99><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend3#">
							<cfelseif ratingbidder LTE 499><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend4#">
							<cfelseif ratingbidder LTE 999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend5#">
							<cfelseif ratingbidder LTE 4999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend6#">
							<cfelseif ratingbidder LTE 9999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend7#">
							<cfelseif ratingbidder LTE 24999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend8#">
							<cfelseif ratingbidder LTE 49999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend9#">
							<cfelseif ratingbidder LTE 99999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend10#">
							<cfelse><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend11#">
							</cfif>
	

</a></b>
									
									<cfif getbidderInfo.mypage neq "">
										<a href="../../personal/mypage.cfm?nickname=#getbidderInfo.nickname#" target="_blank"><img src="/legends/#get_layout.aboutmeicon#"  border="0" align="absbotton"></a>
									</cfif>
       
<cfif #getbidderInfo.membership_status# eq 1>
										<a href="../../help/about_membership.cfm" target="_blank"><img src="/legends/#get_layout.membershipicon#"  border="0" align="absbotton"></a>
									</cfif> 


)</b></cfif>
            <!---<cfif gethighbidder.buynow eq 1><b><a href="#questionLinkBid#">#bidderNickname#</a> (<a href="#VAROOT#/feedback/index.cfm?user_id=#bidderId#">#ratingBidder#</a>)</b></cfif> --->
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Payment
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
              #paymentOpt#
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Shipping
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
              #shippingOpt#
            </font>
          </td>
        </tr>
      </table>
      <br>
	  <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td valign=top>
            <font size=2>
              Seller assumes all responsibility for listing this item.  You should contact 
              the seller to resolve any questions before bidding.  Currency is #Trim(getCurrency.type)# (#currencyName#) unless otherwise noted.
              <br>
              <br>
            </font>
          </td>
        </tr>
      </table>
	  <a name="DESC">
      <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td  bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt">
<table>
<tr>
 <td  bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt" width=800 align="center">

              <b>
                Description 



              </b></td>

<!---
<td width=350 align="right">

<form action="http://babelfish.altavista.com/babelfish/tr" method="POST" target=_blank>
 <input type=hidden name=doit value="done">
 <input type=hidden name=intl value="1">
     
     

 <input type=hidden name=urltext value="#get_Itemdesc.description#">
<nobr><select name="lp" onchange="submit();">

 <option value="">-Translate-</option>

 <option value="en_zh">English to Chinese-simp</option>
 <option value="en_zt">English to Chinese-trad</option>
 <option value="en_nl">English to Dutch</option>
 <option value="en_fr">English to French</option>
 <option value="en_de">English to German</option>
 <option value="en_el">English to Greek</option>
 <option value="en_it">English to Italian</option>
 <option value="en_ja">English to Japanese</option>
 <option value="en_ko">English to Korean</option>
 <option value="en_pt">English to Portuguese</option>
 <option value="en_ru">English to Russian</option>
 <option value="en_es">English to Spanish</option>
 </select>

 
</form>
</td>
--->
</tr>
</table>
</td>
        </tr>
      </table>




      <!--- display description --->
      <table border=0 cellspacing=0 align=center cellpadding=0 noshade width=800>
        <tr>
          <td valign=top align=center>
            #Trim(get_Itemdesc.description)#
            <br>
            <br>
            <cfif isImage>
              <br><img src="#pictureURL#">
            </cfif>




	  <cfif isvalid>
                   
					<cfif #get_itemInfo.picture1# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs\")#>

<cfif fileExists("#thePath##itemnum#.jpg")>




	  <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg"> --->

	  <cfif img_height gt img_width>
	  	<cfset width1 = (Img_width/Img_height) * 500>
	  	<cfset height1 = (Img_height/Img_width) * width1>
	  <cfelseif img_width gt img_height>
	  	<cfset height1 = (Img_height/Img_width) * 500>
	  	<cfset width1 = (Img_width/Img_height) * height1>
<cfelse>
<cfset height1 =500>

	  </cfif> 



	 


<cfelseif fileExists("#thePath##itemnum#.gif")>
	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif"> --->

	  <cfif img_height gt img_width>
	  	<cfset width1 = (Img_width/Img_height) * 500>
	  	<cfset height1 = (Img_height/Img_width) * width1>
	  <cfelse>
	  	<cfset height1 = (Img_height/Img_width) * 500>
	  	<cfset width1 = (Img_width/Img_height) * height1>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  























					<cfif #get_itemInfo.picture2# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs1\")#>

<cfif fileExists("#thePath##itemnum#.jpg")>




	  <! ---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg">--->

	  <cfif img_height gt img_width>
	  	<cfset width2 = (Img_width/Img_height) * 124>
	  	<cfset height2 = (Img_height/Img_width) * width2>
	  <cfelseif img_width gt img_height>
	  	<cfset height2 = (Img_height/Img_width) * 124>
	  	<cfset width2 = (Img_width/Img_height) * height2>
<cfelse>
<cfset height2 = 110>

	  </cfif> 



	 


<cfelseif fileExists("#thePath##itemnum#.gif")>
	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif">--->

	  <cfif img_height gt img_width>
	  	<cfset width2 = (Img_width/Img_height) * 124>
	  	<cfset height2 = (Img_height/Img_width) * width2>
	  <cfelse>
	  	<cfset height2 = (Img_height/Img_width) * 124>
	  	<cfset width2 = (Img_width/Img_height) * height2>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  















					<cfif #get_itemInfo.picture3# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs2\")#>

<cfif fileExists("#thePath##itemnum#.jpg")>




	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg">--->

	  <cfif img_height gt img_width>
	  	<cfset width3 = (Img_width/Img_height) * 124>
	  	<cfset height3 = (Img_height/Img_width) * width3>
	  <cfelseif img_width gt img_height>
	  	<cfset height3 = (Img_height/Img_width) * 124>
	  	<cfset width3 = (Img_width/Img_height) * height3>
<cfelse>
<cfset height3 =124>

	  </cfif> 



	 


<cfelseif fileExists("#thePath##itemnum#.gif")>
	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif">--->

	  <cfif img_height gt img_width>
	  	<cfset width3 = (Img_width/Img_height) * 124>
	  	<cfset height3 = (Img_height/Img_width) * width3>
	  <cfelse>
	  	<cfset height3 = (Img_height/Img_width) * 124>
	  	<cfset width3 = (Img_width/Img_height) * height3>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  







		<cfif #get_itemInfo.picture4# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs3\")#>

<cfif fileExists("#thePath##itemnum#.jpg")>




	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg"> --->

	  <cfif img_height gt img_width>
	  	<cfset width4 = (Img_width/Img_height) * 124>
	  	<cfset height4 = (Img_height/Img_width) * width4>
	  <cfelseif img_width gt img_height>
	  	<cfset height4 = (Img_height/Img_width) * 124>
	  	<cfset width4 = (Img_width/Img_height) * height4>
<cfelse>
<cfset height4 =124>

	  </cfif> 



	 


<cfelseif fileExists("#thePath##itemnum#.gif")>
	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif"> --->

	  <cfif img_height gt img_width>
	  	<cfset width4 = (Img_width/Img_height) * 124>
	  	<cfset height4 = (Img_height/Img_width) * width4>
	  <cfelse>
	  	<cfset height4 = (Img_height/Img_width) * 124>
	  	<cfset width4 = (Img_width/Img_height) * height4>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  




		<cfif #get_itemInfo.picture1# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs\")#>

<cfif fileExists("#thePath##itemnum#.jpg")>




	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg"> --->

	  <cfif img_height gt img_width>
	  	<cfset width5 = (Img_width/Img_height) * 124>
	  	<cfset height5 = (Img_height/Img_width) * width5>
	  <cfelseif img_width gt img_height>
	  	<cfset height5 = (Img_height/Img_width) * 124>
	  	<cfset width5 = (Img_width/Img_height) * height5>
<cfelse>
<cfset height5 =124>

	  </cfif> 



	 


<cfelseif fileExists("#thePath##itemnum#.gif")>
	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif"> --->

	  <cfif img_height gt img_width>
	  	<cfset width5 = (Img_width/Img_height) * 124>
	  	<cfset height5 = (Img_height/Img_width) * width5>
	  <cfelse>
	  	<cfset height5 = (Img_height/Img_width) * 124>
	  	<cfset width5 = (Img_width/Img_height) * height5>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  






	</cfif>    



		<!--- ******** --->
		<cfif isImage1>

 <cfif #get_itemInfo.picture1# is not ""> 


<cfif img_width gt 500>
		

	
		 <br><img src="../../fullsize_thumbs/#picture1URL#" width=#width1# height=#height1# >


		<cfelseif  img_width is "">
<br><img src="../../fullsize_thumbs/#picture1URL#" width=500>

	<cfelse>
		<br><img src="../../fullsize_thumbs/#picture1URL#">

		</cfif>
		</cfif>
		</cfif>
		<!--- ******** --->




            <cfif isSound>
              <br><b>Sound:</b> <a href="#soundURL#">#soundURL#</a>
            </cfif>
          </td>










<td valign=top align="right">
	  <br>
	  <table border=0 cellspacing=0 cellpadding=0 noshade width=130>
	  <tr>
	  <td width=125 valign=top align=left>
	  <table border=0 cellsapcing=2>
			<tr>
			<td>
			<cfif isImage>
              <br><img src="#pictureURL#" width=124 height=110>
            </cfif>
		    </td></tr>
			<tr><td>
		<cfif isImage1>
	

<!---
 <a href="javascript:winOpen1()"><img src="../../fullsize_thumbs/#picture1URL#" width=124 height=110 border=0></a>
		
	--->



<cfif #get_itemInfo.picture1# is not ""> 


<cfif img_width gt 124>
		

		 <a href="javascript:winOpen1()"><img src="../../fullsize_thumbs/#picture1URL#" width=#width5# height=#height5# border=0></a>

		<cfelseif  img_width is "">
		 <a href="javascript:winOpen1()"><img src="../../fullsize_thumbs/#picture1URL#" width=124 height=110 border=0></a>

	<cfelse>
		 <a href="javascript:winOpen1()"><img src="../../fullsize_thumbs/#picture1URL#" border=0></a>

		</cfif>
		</cfif>

	
		</cfif>
		</td></tr>
		<tr><td>
		<cfif isImage2>


<cfif #get_itemInfo.picture2# is not ""> 


<cfif img_width gt 124>
		

		 <a href="javascript:winOpen2()"><img src="../../fullsize_thumbs1/#picture2URL#" width=#width2# height=#height2# border=0></a>

		<cfelseif  img_width is "">
		 <a href="javascript:winOpen2()"><img src="../../fullsize_thumbs1/#picture2URL#" width=124 height=110 border=0></a>

	<cfelse>
		 <a href="javascript:winOpen2()"><img src="../../fullsize_thumbs1/#picture2URL#" border=0></a>

		</cfif>
		</cfif>

	

		

		
		</cfif>
		</td></tr>
		<tr><td>
		<cfif  isImage3>
<!---		
		 <a href="javascript:winOpen3()"><img src="../../fullsize_thumbs2/#picture3URL#" width=124 height=110 border=0></a>
--->


<cfif #get_itemInfo.picture3# is not ""> 


<cfif img_width gt 124>
		

		 <a href="javascript:winOpen3()"><img src="../../fullsize_thumbs2/#picture2URL#" width=#width3# height=#height3# border=0></a>

		<cfelseif  img_width is "">
		 <a href="javascript:winOpen3()"><img src="../../fullsize_thumbs2/#picture3URL#" width=124 height=110 border=0></a>

	<cfelse>
		 <a href="javascript:winOpen3()"><img src="../../fullsize_thumbs2/#picture3URL#" border=0></a>

		</cfif>
		</cfif>

	


		
		</cfif>
		</td></tr>
		<tr><td>
		<cfif  isImage4>
<!---		
		 <a href="javascript:winOpen4()"><img src="../../fullsize_thumbs3/#picture4URL#" width=124 height=110 border=0></a>
--->


<cfif #get_itemInfo.picture4# is not ""> 


<cfif img_width gt 124>
		

		 <a href="javascript:winOpen2()"><img src="../../fullsize_thumbs3/#picture4URL#" width=#width4# height=#height4# border=0></a>

		<cfelseif  img_width is "">
		 <a href="javascript:winOpen4()"><img src="../../fullsize_thumbs3/#picture4URL#" width=124 height=110 border=0></a>

	<cfelse>
		 <a href="javascript:winOpen4()"><img src="../../fullsize_thumbs3/#picture4URL#" border=0></a>

		</cfif>
		</cfif>

	


		
		</cfif>
		</td></tr>
</table>
</td></tr>
</table>

</td>
</tr>



<tr>
			<td align="center"><font color=green size=1>This item  has been viewed</font> <font size="3" color="Red"><b>#hit_cnts#</b></font><font color=green size=1>&nbsp;times.</font></td>
		</tr>



      </table>
      <a name="BID">
      <br>
      
      <!--- if auction still open for bidding --->
      <cfif hAuctionComplete.bComplete IS 0  and get_iteminfo.quantity gt 0 or (get_iteminfo.buynow and get_iteminfo.quantity gt 0 and get_iteminfo.date_end gt #timenow#)>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
          <tr>
            <td bgcolor=#heading_color# align="center" style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt">
                <b>Bidding</b>
            </td>
          </tr>
        </table><br>
        <!--- display bidding info --->
	<table border="3"><tr><td>
	   


<form name="bidForm" action="#VAROOT#/bid/index.cfm" method="POST">
       <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
          <tr>
            <td valign=top align=center colspan="2">
              #Trim(get_ItemInfo.title)# (Item ###get_ItemInfo.itemnum#)
            </td>
          </tr>
		  <tr><td>&nbsp;</td></tr>
		  <!--- <tr>
            <td valign=top>
              <font size=2>
                <br>
                <b>Registration Required.</b>  You must be a registered user in order to 
                place a bid.  <a href="#VAROOT#/registration/index.cfm">Click here</a> to find 
                out how to become a registered user.<br>
              </font>
            </td>
          </tr>
		  <tr>
              <td width=220>
                <b>User ID</b> or <b>Nickname</b><br>
                <input type=text name="nickname" value="#userNickname#" size=20>
              </td>
              <td width=220>
        <b>Password</b> (<a href="#VAROOT#/registration/findpassword.cfm">forgotten it?</a>)<br>
                <input type=password name="password" value="" size=20>

        
              </td>
            </tr> --->
			<input type=hidden name="nickname" value="" size=20>
			<input type=hidden name="password" value="" size=20>
	<!---		<cfif #get_iteminfo.buynow# eq 1 and numberformat(REReplace(minimumBid, "[^0123456789.]", "", "ALL"),'#numbermask#') lte numberformat(get_ItemInfo.buynow_price,'#numbermask#')> --->

<cfif #get_iteminfo.buynow# eq 1 and    #bid_find.recordcount# and #bid_find.total# lt #get_iteminfo.buynow_price#  or (get_iteminfo.buynow and bid_find.recordcount eq 0)>
			<tr>
			<td colspan="2"><table cellspacing="2"><tr>
				<td bgcolor=#heading_color# align="center" width="320" style="color:#heading_fcolor#; font-family:#heading_font#; font-size:11pt">
                Bid
            	</td>
				<td bgcolor=#heading_color# align="center" width="320" style="color:#heading_fcolor#; font-family:#heading_font#; font-size:11pt">
                Buy
            	</td>
				</tr></table></td>
			</tr>

<cfelse>
			<tr>
			<td colspan="2"><table cellspacing="2"><tr>
				<td bgcolor=#heading_color# align="center" width="640" style="color:#heading_fcolor#; font-family:#heading_font#; font-size:11pt">
                Bid
            	</td>

				</tr></table></td>
			</tr>


			</cfif>
			<tr><td <!---<cfif #get_iteminfo.buynow# eq 1 and numberformat(REReplace(minimumBid, "[^0123456789.]", "", "ALL"),'#numbermask#') lte numberformat(get_ItemInfo.buynow_price,'#numbermask#')>
--->
<cfif #get_iteminfo.buynow# eq 1 or (   #bid_find.recordcount# and #bid_find.total# lt #get_iteminfo.buynow_price#  ) or bid_find.recordcount eq 0>

width="320"</cfif>><table>
          <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
            <tr>
			<td><table><tr>
              <td align=left width="150">
                <font size=2>
                  Current Bid
                </font>
              </td>
              <td align=right width="170">
                #bid_currently# #Trim(getCurrency.type)#
              </td>
			  </tr></table></td>
            </tr>
            <tr>
			<td><table><tr>
              <td align=left width="150">
                <font size=2>
                  Bid Increment
                </font>
              </td>
              <td align=right width="170">
                #bidIncrement# #Trim(getCurrency.type)#
              </td>
			  </tr></table></td>
            </tr>
          </cfif>
          <tr>
		  <td><table><tr>
            <td align=left width="150">
              <font size=2>
                <b>Minimum Bid</b>
              </font>
            </td>
            <td align=right width="170">
              <b>#minimumBid# #Trim(getCurrency.type)#</b>
            </td>
			</tr></table></td>
          </tr>
        <!--- </table> --->
        
       
        <!--- display bidding form --->
        
          <!--- <table border=0 cellspacing=0 cellpadding=0 noshade width=640> --->
            
            <tr>
              <td colspan=2>
                <br>
                <!--- quantity if dutch or yankee --->
                <cfif get_ItemInfo.auction_type IS "D" OR get_ItemInfo.auction_type IS "Y">
                  <b>Quantity</b> you are bidding for.<br>
                  <input type=text name="quantity" value="1" size=10><br>
                  <input type=hidden name="bidType" value="REGULAR">
                  <br>
                </cfif>
                <!--- bid type if not dutch or yankee --->
                <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
                  <b><a href="#VAROOT#/help/bidtypes.cfm">Bid type</a>.</b><br>
                  <select name="bidType">
                    <option value="REGULAR"<cfif defBidType IS "REGULAR"> selected</cfif>>Regular bid</option>
                    <option value="PROXY"<cfif defBidType IS "PROXY"> selected</cfif>>Auto bid</option>
                  </select><br>
                  <input type=hidden name="quantity" value="1">
                  <br>
                </cfif>
                <!--- bid --->
                <b>Your Bid.</b><br>
                <input type=text name="bid" value="#REReplace(minimumBid, "[^0123456789.]", "", "ALL")#" size=10 maxlength=10> (The amount you are offering for <cfif get_ItemInfo.auction_type IS "D" OR get_ItemInfo.auction_type IS "Y"><b>each</b><cfelse>this</cfif> item.)<br>
				<input type=hidden name="requiredBid" value="#REReplace(minimumBid, "[^0123456789.]", "", "ALL")#" size=10>
                <br>
                Please enter only numerals and the decimal point.  Do not include 
                currency symbols such as a dollar sign ('$') or commas (',').  Unless 
                otherwise noted, offers are in #Trim(getCurrency.type)# (#currencyName#).<br>
                <br>
                <cfif enableSSL>
                  <b>Use <a href="https://#CGI.SERVER_NAME##VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum#">Secure Sockets Layer</a></b><br>
                  &nbsp;&nbsp;This form is unsecure.  Click the preceeding link if you 
                  would like to use <a href="#VAROOT#/help/ssl.cfm">Secure&nbsp;Sockets&nbsp;Layer</a> 
                  to place a bid on this item.<br>
                  <br>
                </cfif>
                <b>Binding contract.</b><br>
                &nbsp;&nbsp;Placing a bid is a binding contract in many states and provinces. 
                Do not bid unless you intend to buy this item at the amount of your bid.<br>
                <br>
                <!--- auction type, standard or reverse --->
                <cfif get_ItemInfo.auction_type IS "E">
                  <b>This is an <a href="#VAROOT#/help/auctiontypes.cfm##ENGLISH">English auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  English auctions before bidding.<br>
                <cfelseif get_ItemInfo.auction_type IS "V">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##VICKREY">Vickrey auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Vickrey auctions before bidding.<br>
                <cfelseif get_ItemInfo.auction_type IS "D">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##DUTCH">Dutch auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Dutch auctions before bidding.<br>
                <cfelseif get_ItemInfo.auction_type IS "Y">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##YANKEE">Yankee auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Yankee auctions before bidding.<br>
                </cfif>
                &nbsp;&nbsp;If you have bid on this item before, your new bid 
                must be greater than your previous bid.<br>
                <br>
                <input type=submit value="Review Bid" name="reviewBid"><br>
                <input type=hidden name="itemnum" value="#get_ItemInfo.itemnum#">
                <br>
              </td>
			  
            </tr>
			</table></td>
			
			<cfif #get_iteminfo.buynow# eq 1>
<!---				<cfif numberformat(REReplace(minimumBid, "[^0123456789.]", "", "ALL"),'#numbermask#') lte numberformat(get_ItemInfo.buynow_price,'#numbermask#')>

--->

<cfif bid_find.recordcount eq 0 or ( #bid_find.recordcount# and #bid_find.total# lt #get_iteminfo.buynow_price#)>

<!--- ((get_ItemInfo.auction_type IS "E" or get_ItemInfo.auction_type IS "V") and minimumbid lte get_ItemInfo.buynow_price) or ((get_ItemInfo.auction_type IS "D" or get_ItemInfo.auction_type IS "Y") and  getbidsoverbuynow.cnt_bidover_buynow_price lt get_ItemInfo.quantity) --->	
				
			  <td valign="top" align="center">
			  	<table>
					<tr>
						<!--- <td><img src="../../images/dummy_black.gif" width="1" height="100"></td>	 --->
						<td align="left" valign="top" bgcolor="cccccc">
						<a href="../../help/bidtypes.cfm##buynow"><b>Buy now price</b></a><br>
						#numberformat(get_iteminfo.buynow_price, '#numbermask#')#&nbsp;#Trim(getCurrency.type)#
						&nbsp;<input type=submit value="Buy Now" name="buynow_yes">
						</td>
					</tr>
			  	</table>
			  </td>
			  
			  </cfif>
			  </cfif>
			</tr>
          </table>



<cfif isdefined("session.user_id") and session.user_id neq "" and isdefined("session.password") and session.password neq "">

<cfquery name="getuser" datasource="#datasource#">
select nickname, password from users where user_id = #session.user_id# and password='#session.password#'
</cfquery>

<input type=hidden name="password" value="#session.password#">
<input type=hidden name="nickname" value="#getuser.nickname#">



<cfset #session.nickname# = #getuser.nickname#>


</cfif>

        </form>
		</td></tr></table>
      </cfif>      

      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td>
            <!--- include menu bar --->
            <center>
       
              <font size=2>

              </font>
              <br>
              <br>
            </center>
          </td>
        </tr>
      </table>
      <br>
      <br>
      <!--- if iescrow enabled, display --->
      <!---<cfif hIEscrow.bEnabled>
        
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td valign=bottom><a href="#hIEscrowIcons.sIEHomeURL#"><img src="#hIEscrowIcons.sURL##hIEscrowIcons.sCurrentOption#" border=0></a></td>
            <td align=left valign=bottom>
              <font size=2>
                For the convenience of credit card payment and the opportunity<br>to inspect 
                your purchase, consider safe, easy-to-use escrow services.
              </font>
            </td>
          </tr>
        </table>
        <br>
      </cfif> --->
      <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td align=left valign=top>
                        <hr size=1 color=#heading_color# width=100%>
            <font size=2>
               <cfinclude template="../../includes/copyrights.cfm">
               <br>
               <br>
               <br>
            </font>
          </td>
        </tr>
      </table>
    </center>
  </body>
</html>

</cfoutput>



<!---  --->
<!---  --->
<!---  --->
<!---  --->




<cfelse>
<!--Reverse Auction  -------------------------------------------------->
<!--- if valid item get rest of info --->
<cfif isvalid>
  <!--- enable Session state management --->
  <cfset mins_until_timeout = 60>
  <cfapplication name="UserManagement" sessionmanagement="Yes" sessiontimeout="#CreateTimeSpan(0, 0, mins_until_timeout, 0)#">
  
  <!--- get currency type --->
  <cfquery username="#db_username#" password="#db_password#" name="getCurrency" datasource="#DATASOURCE#">
      SELECT pair AS type
        FROM defaults
       WHERE name = 'site_currency'
  </cfquery>
  
  <!--- def currency name --->
  <cfmodule template="../../functions/cf_currencies.cfm"
    mode="CODECONVERT"
    code="#Trim(getCurrency.type)#"
    return="currencyName">
  
  <!--- def if auction complete --->
  <cfmodule template="../../functions/auction_complete.cfm"
    iItemnum = "#itemnum#">
    
  <cftry>
    <!--- get category name of item --->
    <cfquery username="#db_username#" password="#db_password#" name="get_CategoryInfo" datasource="#DATASOURCE#">
        SELECT name,category
          FROM categories
         WHERE category = #get_ItemInfo.category1#
    </cfquery>
    
    <cfset category_name = Trim(get_CategoryInfo.name)>
    
    <cfcatch>
      <cfset category_name = "Not Available">
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get current low bid --->
    <cfquery name="get_LowBid" datasource="#DATASOURCE#">
        SELECT MIN(bid) AS lowest
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#

    </cfquery>
    
    <cfif not get_LowBid.RecordCount>
      <cfthrow>
    </cfif>
    
    <cfset current_bid = get_LowBid.lowest>
    
    <cfcatch>
      <cfset current_bid = get_ItemInfo.maximum_bid>
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get seller's info --->
    <cfquery name="get_SellerInfo" datasource="#DATASOURCE#">
        SELECT nickname, email,mypage
          FROM users
         WHERE user_id = #get_ItemInfo.user_id#
    </cfquery>
    
    <cfset seller_nickname = Trim(get_SellerInfo.nickname)>
    <cfset seller_email = Trim(get_SellerInfo.email)>
    
    <cfcatch>
      <cfset seller_nickname = "Not Available">
      <cfset seller_email = "Not Available">
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get parents of this category --->
    <cfmodule template="../../functions/parentlookup.cfm"
      CATEGORY="#get_ItemInfo.category1#"
      DATASOURCE="#DATASOURCE#"
      RETURN="parents_array">
    
    <cfcatch>
      <cfset parents_array = ArrayNew(2)>
    </cfcatch>
  </cftry>
  
  <cftry>
    <!--- get current bid, number of bids, define reserve met --->
    <cfquery name="get_LowBid" datasource="#DATASOURCE#">
        SELECT MIN(bid) AS lowest, COUNT(bid) AS bidcount
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#
    </cfquery>
    
    <cfset bid_currently = IIf(get_LowBid.bidcount, "get_LowBid.lowest", "get_ItemInfo.maximum_bid")>
    <cfset bid_count = get_LowBid.bidcount>
    
    <cfif get_ItemInfo.auction_type IS "V">
      <cfquery name="getSecondBid" datasource="#DATASOURCE#" maxrows=2>
          SELECT bid
            FROM bids
           WHERE itemnum = #get_ItemInfo.itemnum#
           ORDER BY bid ASC
      </cfquery>
      
      <cfloop query="getSecondBid">
        <cfset secondBidder = getSecondBid.bid>
      </cfloop>
      
      <!--- if bids on item --->
      <cfif getSecondBid.RecordCount>
        
        <cfset reserve_met = IIf(secondBidder GT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
      <cfelse>
        
        <cfset reserve_met = IIf(bid_currently GT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
      </cfif>
      
    <cfelse>
      <cfset reserve_met = IIf(bid_currently GT get_ItemInfo.reserve_bid, DE("(reserve not met)"), DE(""))>
    </cfif>
    
    <cfcatch>
      <cfset bid_currently = "Not Available">
      <cfset reserve_met = "not available">
      <cfset bid_count = "Not Available">
    </cfcatch>
  </cftry>
  
  <!--- define time left --->
  <cfif hAuctionComplete.bComplete>
    <cfset timeleft = '<font color=ff0000>COMPLETED</font>'>
  <cfelse>
    <cfset timeleft = hAuctionComplete.tsDateEnd - TIMENOW>
    <cfif timeleft GT 1>
      <cfset daysleft = IIf(Int(timeleft) LT 0, DE("0"), "Int(timeleft)")>
      <cfset hrsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('h', timeleft)")>
      <cfset minsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('n', timeleft)")>
      <cfset dayslabel = IIf(daysleft IS 1, DE("day"), DE("days"))>
      <cfset hrslabel = IIf(hrsleft IS 1, DE("hour"), DE("hours"))>
      <cfset timeleft = daysleft & " " & dayslabel & ", " & hrsleft & " " & hrslabel & " +">
    <cfelse>
      <cfset hrsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('h', timeleft)")>
      <cfset minsleft = IIf(Int(timeleft) LT 0, DE("0"), "DatePart('n', timeleft)")>
      <cfset hrslabel = IIf(hrsleft IS 1, DE("hour"), DE("hours"))>
      <cfset minslabel = IIf(minsleft IS 1, DE("min"), DE("mins"))>
      <cfset timeleft = hrsleft & " " & hrslabel & ", " & minsleft & " " & minslabel & " +">
    </cfif>
  </cfif>
  
  <!--- define started date format --->
  <cfset started = DateFormat(get_ItemInfo.date_start, "mm/dd/yy") & " " & TimeFormat(get_ItemInfo.date_start, "HH:mm:ss")>
  
  <!--- define ends date format --->
  <cfset ends = DateFormat(hAuctionComplete.tsDateEnd, "mm/dd/yy") & " " & TimeFormat(hAuctionComplete.tsDateEnd, "HH:mm:ss")>
  
  <!--- define seller's feedback rating --->
  <cftry>
    <cfquery name="get_SellerFeedback" datasource="#DATASOURCE#">
        SELECT SUM(rating) AS ratinglevel, COUNT(rating) AS totalfeed
          FROM feedback
         WHERE user_id = #get_ItemInfo.user_id#
    </cfquery>
    
    <cfif get_SellerFeedback.totalfeed>
      <cfset ratingSeller = Round(get_SellerFeedback.ratinglevel)>
    <cfelse>
      <cfset ratingSeller = 0>
    </cfif>
    
    <cfcatch>
      <cfset ratingSeller = "not available">
    </cfcatch>
  </cftry>
  
  <!--- define "ask seller question" link value --->
  <cfif get_ItemInfo.private is 1>
    <cfset questionLinkSell = "#VAROOT#/messaging/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">
  <cfelse>
    <cfset questionLinkSell = "mailto:" & seller_email>
  </cfif>
  
  <!--- get high bidder info --->
  <cftry>
    <cfquery name="getLowBidder" datasource="#DATASOURCE#" maxrows="1">
        SELECT user_id
          FROM bids
         WHERE itemnum = #get_ItemInfo.itemnum#
         ORDER BY bid ASC
    </cfquery>
    
    <cfquery name="getBidderInfo" datasource="#DATASOURCE#">
        SELECT nickname, email,mypage
          FROM users
         WHERE user_id = #getLowBidder.user_id#
    </cfquery>
    
    <cfquery name="getBidderRating" datasource="#DATASOURCE#">
        SELECT SUM(rating) AS ratinglevel, COUNT(rating) AS totalfeed
          FROM feedback
         WHERE user_id = #getLowBidder.user_id#
    </cfquery>
    
    <cfif getBidderInfo.RecordCount>
      <cfset bidderNickname = Trim(getBidderInfo.nickname)>
      <cfset bidderEmail = Trim(getBidderInfo.email)>
      <cfset bidderId = getLowBidder.user_id>
    <cfelse>
      <cfset bidderNickname = "Not Available">
      <cfset bidderEmail = "Not Available">
    </cfif>
    
    <cfif getBidderRating.totalfeed>
      <cfset ratingBidder = Round(getBidderRating.ratinglevel)>
    <cfelse>
      <cfset ratingBidder = 0>
    </cfif>
    
    <cfcatch>
      <cfset bidderNickname = "Not Available">
      <cfset bidderEmail = "Not Available">
      <cfset ratingBidder = "not available">
      <cfset bidderId = "not available">
    </cfcatch>
  </cftry>
  
  <!--- define "mailto" link value --->
  <cfif get_ItemInfo.private is 1>
    <cfset questionLinkBid = "#VAROOT#/messaging/index.cfm?user_id=" & bidderId>
  <cfelse>
    <cfset questionLinkBid = "mailto:" & bidderEmail>
  </cfif>
  
  <!--- define payment options --->
  <cfmodule template="../../functions/options_list.cfm"
    mode="PAYMENT"
    morder_ccheck="#get_ItemInfo.pay_morder_ccheck#"
    cod="#get_ItemInfo.pay_cod#"
    see_desc="#get_ItemInfo.pay_see_desc#"
    pcheck="#get_ItemInfo.pay_pcheck#"
    ol_escrow="#get_ItemInfo.pay_ol_escrow#"
    other="#get_ItemInfo.pay_other#"
    visa_mc="#get_ItemInfo.pay_visa_mc#"
    am_express="#get_ItemInfo.pay_am_express#"
    discover="#get_ItemInfo.pay_discover#">
  
  <!--- define shipping options --->
  <cfmodule template="../../functions/options_list.cfm"
    mode="SHIPPING"
    sell_pays="#get_ItemInfo.ship_sell_pays#"
    buy_pays_act="#get_ItemInfo.ship_buy_pays_act#"
    see_desc="#get_ItemInfo.ship_see_desc#"
    buy_pays_fxd="#get_ItemInfo.ship_buy_pays_fxd#"
    international="#get_ItemInfo.ship_international#">
  
  <!--- define pictureURL --->
  <cfif Right(get_ItemInfo.picture, 4) IS ".gif"
   OR Right(get_ItemInfo.picture, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture, 4) IS ".png">
    <cfset isImage = "TRUE">
    <cfset pictureURL = Trim(get_ItemInfo.picture)>
  <cfelse>
    <cfset isImage = "FALSE">
  </cfif>
  
  <!--- define picture1URL --->
  <cfif Right(get_ItemInfo.picture1, 4) IS ".gif"
   OR Right(get_ItemInfo.picture1, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture1, 4) IS ".png">
    <cfset isImage1 = "TRUE">
    <cfset picture1URL = Trim(get_ItemInfo.picture1)>
  <cfelse>
    <cfset isImage1 = "FALSE">
  </cfif>
  <!--- define picture2URL --->
  <cfif get_ItemInfo.picture2 neq "" 
   and (Right(get_ItemInfo.picture2, 4) IS ".gif"
   OR Right(get_ItemInfo.picture2, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture2, 4) IS ".png")>
    <cfset isImage2 = "TRUE">
    <cfset picture2URL = Trim(get_ItemInfo.picture2)>
  <cfelse>
     <cfset isImage2 = "FALSE">  
  </cfif>
  <!--- define picture3URL --->
  <cfif get_ItemInfo.picture3 neq "" 
   and (Right(get_ItemInfo.picture3, 4) IS ".gif"
   OR Right(get_ItemInfo.picture3, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture3, 4) IS ".png")>
    <cfset isImage3 = "TRUE">
    <cfset picture3URL = Trim(get_ItemInfo.picture3)>
  <cfelse>
     <cfset isImage3 = "FALSE">  
  </cfif>
  
   <!--- define picture4URL --->
  <cfif get_ItemInfo.picture4 neq "" 
   and (Right(get_ItemInfo.picture4, 4) IS ".gif"
   OR Right(get_ItemInfo.picture4, 4) IS ".jpg"
   OR Right(get_ItemInfo.picture4, 4) IS ".png")>
    <cfset isImage4 = "TRUE">
    <cfset picture4URL = Trim(get_ItemInfo.picture4)>
  <cfelse>
      <cfset isImage4 = "FALSE"> 
  </cfif>
  <!--- define soundURL --->
  <cfif Right(get_ItemInfo.sound, 4) IS ".wav" 
   OR Right(get_ItemInfo.sound, 3) IS ".au" 
   OR Right(get_ItemInfo.sound, 3) IS ".ra" 
   OR Right(get_ItemInfo.sound, 4) IS ".mp3" 
   OR Right(get_ItemInfo.sound, 4) IS ".mid">
    <cfset isSound = "TRUE">
    <cfset soundURL = Trim(get_ItemInfo.sound)>
  <cfelse>
    <cfset isSound = "FALSE">
  </cfif>
  
  <!--- define studioPictureURL --->
  <cfif get_ItemInfo.studio>
    <cfif Right(get_ItemInfo.picture_studio, 4) IS ".gif" 
      OR Right(get_ItemInfo.picture_studio, 4) IS ".jpg"
      OR Right(get_ItemInfo.picture_studio, 4) IS ".png">
      <cfset isStudioImage = "TRUE">
      <cfset studioPictureURL = Trim(get_ItemInfo.picture_studio)>
    <cfelse>
      <cfset isStudioImage = "FALSE">
    </cfif>
  <cfelse>
    <cfset isStudioImage = "FALSE">
  </cfif>
  
  <!--- define studioSoundURL --->
  <cfif get_ItemInfo.studio>
    <cfif Right(get_ItemInfo.sound_studio, 4) IS ".wav" 
      OR Right(get_ItemInfo.sound_studio, 3) IS ".au" 
      OR Right(get_ItemInfo.sound_studio, 3) IS ".ra" 
      OR Right(get_ItemInfo.sound_studio, 4) IS ".mp3" 
      OR Right(get_ItemInfo.sound_studio, 4) IS ".mid">
      <cfset isStudioSound = "TRUE">
      <cfset studioSoundURL = Trim(get_ItemInfo.sound_studio)>
    <cfelse>
      <cfset isStudioSound = "FALSE">
    </cfif>
  <cfelse>
    <cfset isStudioSound = "FALSE">
  </cfif>
  
  <!--- bidIncrement & maximumBid --->
  <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
    <cfset bidIncrement = IIf(get_ItemInfo.increment, "get_ItemInfo.increment_valu", "0.01")>
    <cfset maximumBid = numberFormat(Evaluate(bid_currently - bidIncrement),numbermask)>
    <cfset bidIncrement = numberFormat(bidIncrement,numbermask)>
	<cfif get_LowBid.bidcount LT 1>
	<cfset maximumBid = numberFormat(bid_currently,numbermask)>
	</CFIF>
	
  <cfelse>
  <cfset bidIncrement = IIf(get_ItemInfo.increment, "get_ItemInfo.increment_valu", "get_ItemInfo.increment_valu")>
    <cfmodule template="../../functions/dutch_bidding.cfm"
		itemnum="#get_itemInfo.itemnum#"
		quantity="#get_itemInfo.quantity#"
		maximum_bid = "#get_itemInfo.maximum_bid#">
    <cfset maximumBid = numberformat(maximumBid,numbermask)>
  </cfif>
  <cfset bid_currently = numberFormat(bid_currently,numbermask)>
  
  <!--- define userNickname if Session available --->
  <cftry>
    <cfif IsDefined("Session.nickname")>
      <cfset userNickname = Session.nickname>
    <cfelse>
      <cfset userNickname = "">
    </cfif>
    
    <cfcatch>
      <cfset userNickname = "">
    </cfcatch>
  </cftry>
  
  <!--- get default bid type --->
  <cftry>
    <cfquery username="#db_username#" password="#db_password#" name="getDefBidType" datasource="#DATASOURCE#">
        SELECT pair AS def_bidding
          FROM defaults
         WHERE name = 'def_bidding'
    </cfquery>
    
    <cfset defBidType = getDefBidType.def_bidding>
    
    <cfcatch>
      <cfset defBidType = "REGULAR">
    </cfcatch>
  </cftry>
  
  <!--- get enable_ssl --->
  <cftry>
    <cfquery username="#db_username#" password="#db_password#" name="getSSL" datasource="#DATASOURCE#">
        SELECT pair AS enable_ssl
          FROM defaults
         WHERE name = 'enable_ssl'
    </cfquery>
    
    <cfset enableSSL = getSSL.enable_ssl>
    
    <cfcatch>
      <cfset enableSSL = "FALSE">
    </cfcatch>
  </cftry>
</cfif>

<!--- get bool iescrow enabled --->
<cfmodule template="../../functions/iescrow.cfm"
  sOpt="ChkStatus">

<!--- if iescrow enabled, get current vals --->
<cfif hIEscrow.bEnabled>
  
  <cfmodule template="../../functions/IEscrowIcons.cfm"
    sOpt="DISP/FRONTPAGE">
</cfif>

<cfmodule template="../../functions/browsercheck.cfm">


<!--- output information --->
<cfsetting enablecfoutputonly="No">
<cfset reverse_icon = '<IMG SRC="../../images/R_reverse.gif" width=22 height=17 border=0 alt="This is a Reverse Auction">'>
<script language="JavaScript">
<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture1URL")> 
  function winOpen1(){
  msgWindow=window.open("large_pic.cfm?Image=1&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif> 
<cfelse>

<cfif isdefined("picture1URL")> 
  function winOpen1() {

   s="../../fullsize_thumbs/<cfoutput>#picture1URL#</cfoutput>"
   detailWin = window.open(s,"title1","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=450,height=450,left=10,top=120,alwaysRaised=yes");
//  detailWin.location.reload(true);

  }

</cfif>
</cfif> 

<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture2URL")>
  function winOpen2(){
  msgWindow=window.open("large_pic.cfm?Image=2&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif>
<cfelse>
  <cfif isdefined("picture2URL")>
  function winOpen2() {
  s="../../fullsize_thumbs0/<cfoutput>#picture2URL#</cfoutput>"
  detailWin = window.open(s,"title2","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 // detailWin.location.reload(true);
  }
  </cfif>
</cfif>

<cfif #bc_version# GT 4.5>
  <cfif isdefined("picture3URL")>
  function winOpen3(){
  msgWindow=window.open("large_pic.cfm?Image=3&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        } 
  </cfif>
<cfelse>
  <cfif isdefined("picture3URL")>
  function winOpen3() {
  s="../../fullsize_thumbs1/<cfoutput>#picture3URL#</cfoutput>"
  detailWin = window.open(s,"title3","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 // detailWin.location.reload(true);
  }
  </cfif>
</cfif>

<cfif #bc_version# GT 4.5>
 <cfif isdefined("picture4URL")>
 function winOpen4(){
 msgWindow=window.open("large_pic.cfm?Image=4&itemnum=<cfoutput>#itemnum#</cfoutput>&title=<cfoutput>#get_ItemInfo.title#</cfoutput>","displayWindow","toolbar=no,top=120,left=10,width=450,height=450,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no")
        }
 </cfif>
<cfelse>
  <cfif isdefined("picture4URL")>
  function winOpen4() {
  s="../../fullsize_thumbs2/<cfoutput>#picture4URL#</cfoutput>"
  detailWin = window.open(s,"title4","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=450,height=450,left=10,top=120,alwaysRaised=yes");
 //detailWin.location.reload(true);
}
  </cfif>
</cfif> 
</script>

<cfoutput>

<html>
  <head>
    <title><cfif isvalid>Item #get_ItemInfo.itemnum# (#Trim(get_ItemInfo.title)#)<cfelse>Item Not Found</cfif></title>

    <link rel=stylesheet href="#VAROOT#/includes/stylesheet.css" type="text/css">


  </head>
  
  
  <script language = "javascript">
      function inspector(){
			if (!window.popup){  // has not yet been defined
    	  popup=window.open("http://dev07.beyondsolutions.com/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=250,width=206,top=110,left=520");
//			  self.focus()
				popup.document.close()
			}else{
				if (!popup.closed){ // has been defined
    	    popup.focus()
				}else{
				  popup=window.open("http://dev07.beyondsolutions.com/inspector/inspector.cfm?inspector=#get_ItemInfo.inspector#","picWin","height=250,width=206,top=110,left=520")
					popup.document.close()
				}
  		}
		}
//		inspector()
  </script>  



  

        <!--- <cfinclude template="../../includes/bigtime.cfm"> --->

  <cfinclude template="../../includes/bodytag.html">
    <center>
    <table border=0 cellspacing=0 cellpadding=0 noshade width="800" align="center">
                <cfinclude template="../../includes/menu_bar.cfm">
      <table border=0 cellspacing=0 cellpadding=0 noshade width=100%>
        <tr>
          <td>
             <!--- include menu bar --->
            <center>
       
              <font size=2>

              </font>
              <br>
            </center>
          </td>
        </tr>
      </table>
      <br>

     <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td>
            <font size=4>


              <cfif auction_mode is 1>
                <cfset reverse_icon = '<IMG SRC="#varoot#/images/R_reverse.gif" width=22 height=17 border=0 alt="This is a Reverse Auction">'>
              </CFIF>


              <b>
              <cfif isvalid>
                <cfif #get_ItemInfo.studio# IS 1 and #get_ItemInfo.hide# IS 0>
                  <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","thumbs\")#>
                  <cfif fileExists("#thePath##itemnum#.jpg")>
	 <!--- <CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg"> --->
<cfif img_height is "" or img_width is "">
<table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG width=124 height=110 src="#varoot#/thumbs/#itemnum#.jpg" border=0></a></td></tr></table><br>
<cfelse>
	  <cfif img_height gt img_width>
	  	<cfset width = (Img_width/Img_height) * 124>
	  	<cfset height = (Img_height/Img_width) * width>
	  <cfelse>
	  	<cfset height = (Img_height/Img_width) * 124>
	  	<cfset width = (Img_width/Img_height) * height>
	  </cfif>
     <table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG src=#varoot#/thumbs/#itemnum#.jpg width=#width# height=#height# border="0"></a></td></tr></table>
</cfif>
    <cfelseif fileExists("#thePath##itemnum#.gif")>
	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif">--->
<cfif img_height is "" or img_width is "">
<table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG width=124 height=110 src="#varoot#/thumbs/#itemnum#.gif" border=0></a></td></tr></table><br>
<cfelse>
	  <cfif img_height gt img_width>
	  	<cfset width = (Img_width/Img_height) * 124>
	  	<cfset height = (Img_height/Img_width) * width>
	  <cfelse>
	  	<cfset height = (Img_height/Img_width) * 124>
	  	<cfset width = (Img_width/Img_height) * height>
	  </cfif>
     <table bgcolor=000000><tr><td align=center width=124 height=110>       <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><IMG src=#varoot#/thumbs/#itemnum#.gif width=#width# height=#height# border="0"></a></td></tr></table>
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>      


				   </cfif>
                
              <cfelse>
                Not Found
              </cfif></b>
            </font>
			</td>
			<td width="100%">
		  	<table width="100%" bgcolor=#heading_color#><tr><td width="640" align="center" valign="middle">
		  	<FONT size="4" COLOR=#heading_fcolor#>
				<b>#Trim(get_ItemInfo.title)##reverse_icon#</b>
			</font>
			            <hr size=2 color=#heading_color# width=100%>
            <FONT COLOR=white><cfif isvalid><b>Item ## #get_ItemInfo.itemnum#<cfif get_ItemInfo.banner> - #get_ItemInfo.banner_line#</cfif></b></font></cfif>
			</td></tr></table>
		  </td>
        </tr>
      </table>
      
      <cfif not isvalid>
              Item not found... please try another item.
            </center>
          </body>
        </html>
        <cfabort>
      </cfif>
      
      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td>
            <font size=2>
              <center>
                <br>








    <cfsetting enablecfoutputonly="Yes">
                <!--- output parents --->
                <cfloop index="i" from="#ArrayLen(parents_array)#" to="1" step="-1">
                  <cfif i IS ArrayLen(parents_array)>
                    <cfset link = "#VAROOT#/listings/categories/index.cfm">
                  <cfelse>
                    <cfset link = "#VAROOT#/listings/categories/index.cfm?category=#parents_array[i][2]#">
                  </cfif>



                 <a href="#link#"><font color=#heading_color# size=3><b><i>#parents_array[i][1]#</b></i></font></a>: 


                </cfloop>

<a href="#VAROOT#/listings/categories/index.cfm?category=#get_categoryinfo.category#"><font color=#heading_color# size=3><b><i>  #Variables.category_name#:</b></i></font></a>



        <cfsetting enablecfoutputonly="No">
              
 

<br>
<br>
            <font size=1 color=#heading_color#><b>
<i>              Server time :#DateFormat(TIMENOW, "mmm-d-yyyy")#, #TimeFormat(TIMENOW, "HH:mm:sstt")#;&nbsp #TIME_ZONE#
</i></b>            </font>






<!---

                <cfsetting enablecfoutputonly="Yes">
                <!--- output parents --->
                <cfloop index="i" from="#ArrayLen(parents_array)#" to="1" step="-1">
                  #parents_array[i][1]#: 
                </cfloop>
                #Variables.category_name#:
                <cfsetting enablecfoutputonly="No">


--->
              </center>
            </font>
          </td>
        </tr>
      </table><br>
	  
      <!-- auction information -->
      <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td rowspan=10 valign=top align=left nowrap><!---  width=80 --->
            <font size=2>
              <br>
              <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###DESC"><img src="#VAROOT#/legends/#get_layout.descriptionicon#" border="0" align="absmiddle">&nbsp;Description</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <br>
              <br>
              <br>
              <br>
              
              <!--- auction is still running, including dynamic bid --->
              <cfif hAuctionComplete.bComplete IS 0>
                <a href="#VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum###BID"><img src="#VAROOT#/legends/#get_layout.bidicon#" border="0" align="absmiddle">&nbsp;Offer</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              </cfif>
              
            </font>
          </td>
          <td width=80 valign=top>
            <font size=2>
              Currently
            </font>
          </td>
          <td width=200 valign=top>
            <font size=2>
              <b>#bid_currently# #Trim(getCurrency.type)#</b> #reserve_met#
			  <a href="http://www.xe.com/pca/launch.cgi?Amount=#bid_currently#&From=#getcurrency.type#&ToSelect=USD"><img src="../../images/small_calc1.gif" border=0 alt="The Currency Converter"></a>
 <!--- <a href="javascript:showCalc()"><img src="../../images/small_calc1.gif" border=0 alt="The Currency Converter"></a> ---> 
            </font>
          </td>
          <td width=80 valign=top>
            <font size=2>
              First Offer
            </font>
          </td>
          <td width=200 valign=top>
            <font size=2>
              #numberFormat(get_ItemInfo.maximum_bid,numbermask)# #Trim(getCurrency.type)#
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Quantity
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#get_ItemInfo.quantity#</b>
            </font>
          </td>
          <td valign=top>
            <font size=2>
              ## of Offers
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#bid_count#</b> (<a href="#VAROOT#/listings/details/bidhistory.cfm?itemnum=#get_ItemInfo.itemnum#">Offers history</a>)
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Time Left
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#timeleft#</b>
            </font>
          </td>
          <td valign=top>
            <font size=2>
              Location
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b>#Trim(get_ItemInfo.location)#</b>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Started
            </font>
          </td>
          <td valign=top>
            <font size=2>
              #started#
            </font>
          </td>
          <td valign=top>
            <font size=2>
            Country
            </font>
          </td>
          <td valign=top>
            <font size=2>
            <b>#Trim(get_ItemInfo.country)#</b>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Ends
            </font>
          </td>
          <td valign=top>
            <font size=2>
              #ends#
            </font>
          </td>
          <td colspan=2 valign=top>
            <font size=2>
              (<a href="#VAROOT#/listings/details/emailauction.cfm?itemnum=#get_ItemInfo.itemnum#">mail this auction to a friend</a>)
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Buyer
            </font>
          </td>
          <td valign=top>
            <font size=2>
              <b><a href="#questionLinkSell#">#seller_nickname#</a> (<a href="#VAROOT#/feedback/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">#ratingSeller#</a>



<b><a href="#VAROOT#/feedback/legend.cfm">							<cfif ratingSeller LTE 9>
<img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend1#">
							<cfelseif ratingSeller LTE 49><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend2#">
							<cfelseif ratingSeller LTE 99><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend3#">
							<cfelseif ratingSeller LTE 499><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend4#">
							<cfelseif ratingSeller LTE 999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend5#">
							<cfelseif ratingSeller LTE 4999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend6#">
							<cfelseif ratingSeller LTE 9999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend7#">
							<cfelseif ratingSeller LTE 24999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend8#">
							<cfelseif ratingSeller LTE 49999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend9#">
							<cfelseif ratingSeller LTE 99999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend10#">
							<cfelse><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend11#">
							</cfif>
	

</a></b>
									
									<cfif get_SellerInfo.mypage neq "">
										<a href="../../personal/mypage.cfm?nickname=#get_SellerInfo.nickname#" target="_blank"><img src="/legends/#get_layout.aboutmeicon#"  border="0" align="absbotton"></a>
									</cfif>
        

)</b>
            </font>
          </td>
          
          <td colspan=2 valign=top>
		  	<font size=2>
              (<a href="#VAROOT#/personal/add_watchlist.cfm?itemnum=#get_ItemInfo.itemnum#">Watch this item</a>)
            </font>
		  </td>     
          
        </tr>
        <tr>
          <td></td>
          <td colspan=3 valign=top>
            <font size=2>
              (<a href="#VAROOT#/feedback/index.cfm?user_id=#get_ItemInfo.user_id#&itemnum=#get_ItemInfo.itemnum#">view feedback on buyer</a>) (<a href="#VAROOT#/search/search_results.cfm?search_type=seller_search&search_text=#get_ItemInfo.user_id#&search_name=Search+by+Seller&auction_mode=#auction_mode#">view other auctions by buyer</a>) (<a href="#questionLinkSell#">ask buyer a question</a>)
            </font>
          <cfif #get_ItemInfo.inspector# is not "">
          <font size=2>
            <a href="javascript:inspector()">(Check this item with The Inspector)</a>&nbsp;<img src="../../images/loupe.gif" height=16 width=16 border=0>
<!---            <script language="javascript">inspector()</script>
--->
          </font>            
          </cfif>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Low bid
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
              <cfif bidderNickname IS NOT "Not Available"><b><a href="#questionLinkBid#">#bidderNickname#</a> (<a href="#VAROOT#/feedback/index.cfm?user_id=#bidderId#">#ratingBidder#</a>



<b><a href="#VAROOT#/feedback/legend.cfm">			<cfif ratingbidder LTE 9>
<img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend1#">
							<cfelseif ratingbidder LTE 49><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend2#">
							<cfelseif ratingbidder LTE 99><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend3#">
							<cfelseif ratingbidder LTE 499><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend4#">
							<cfelseif ratingbidder LTE 999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend5#">
							<cfelseif ratingbidder LTE 4999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend6#">
							<cfelseif ratingbidder LTE 9999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend7#">
							<cfelseif ratingbidder LTE 24999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend8#">
							<cfelseif ratingbidder LTE 49999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend9#">
							<cfelseif ratingbidder LTE 99999><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend10#">
							<cfelse><img align="ABSMIDDLE" border="0" src="/legends/#get_layout.legend11#">
							</cfif>
</a></b>
									<b>)</b>
									<cfif getbidderInfo.mypage neq "">
										<a href="../../personal/mypage.cfm?nickname=#get_SellerInfo.nickname#" target="_blank"><img src="/legends/#get_layout.aboutmeicon#"  border="0" align="absbotton"></a>
									</cfif>
        
)</b></cfif>
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Payment
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
              #paymentOpt#
            </font>
          </td>
        </tr>
        <tr>
          <td valign=top>
            <font size=2>
              Shipping
            </font>
          </td>
          <td colspan=3 valign=top>
            <font size=2>
              #shippingOpt#
            </font>
          </td>
        </tr>
      </table>
      <br>
	  <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td valign=top>
            <font size=2>
              The Buyer assumes all responsibility for listing this item.  You should contact 
              the buyer to resolve any questions before making an offer.  Currency is #Trim(getCurrency.type)# (#currencyName#) unless otherwise noted.
              <br>
              <br>
            </font>
          </td>
        </tr>
	  </table>
	  <a name="DESC">
	  <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
        <tr>
          <td align="center" bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt">
             <table>
<tr>
 <td  bgcolor=#heading_color# style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt" width=370 align="right">

              <b>
                Description 



              </b></td>


<td width=270 align="right">
<!---
<form action="http://babelfish.altavista.com/babelfish/tr" method="POST" target=_blank>
 <input type=hidden name=doit value="done">
 <input type=hidden name=intl value="1">
     
     

 <input type=hidden name=urltext value="#get_Itemdesc.description#">
<nobr><select name="lp" onchange="submit();">

 <option value="">-Translate-</option>

 <option value="en_zh">English to Chinese-simp</option>
 <option value="en_zt">English to Chinese-trad</option>
 <option value="en_nl">English to Dutch</option>
 <option value="en_fr">English to French</option>
 <option value="en_de">English to German</option>
 <option value="en_el">English to Greek</option>
 <option value="en_it">English to Italian</option>
 <option value="en_ja">English to Japanese</option>
 <option value="en_ko">English to Korean</option>
 <option value="en_pt">English to Portuguese</option>
 <option value="en_ru">English to Russian</option>
 <option value="en_es">English to Spanish</option>
 </select>

 
</form>
--->
</td>
</tr>
</table>
</td>
        </tr>
      </table>




      <!--- display description --->
      <table border=0 cellspacing=0 align=center cellpadding=0 noshade width=640>
        <tr>
          <td valign=top align=center>
            #Trim(get_Itemdesc.description)#
            <br>
            <br>
            <cfif isImage>
              <br><img src="#pictureURL#">
            </cfif>




	  <cfif isvalid>
                   
					<cfif #get_itemInfo.picture1# is not "">
                      <cfset #thePath# = #Replace(GetDirectoryFromPath(GetTemplatePath()),"listings\details\","fullsize_thumbs\")#>
                      
<cfif fileExists("#thePath##itemnum#.jpg")>
	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.jpg">--->

	  <cfif img_height gt img_width>
	  	<cfset width1 = (Img_width/Img_height) * 500>
	  	<cfset height1 = (Img_height/Img_width) * width1>
	  <cfelse>
	  	<cfset height1 = (Img_height/Img_width) * 500>
	  	<cfset width1 = (Img_width/Img_height) * height1>
	  </cfif> 
	 

<cfelseif fileExists("#thePath##itemnum#.gif")>
	  <!---<CFX_GIFGD ACTION="READ" FILE="#thePath##itemnum#.gif">--->

	  <cfif img_height gt img_width>
	  	<cfset width1 = (Img_width/Img_height) * 500>
	  	<cfset height1 = (Img_height/Img_width) * width1>
	  <cfelse>
	  	<cfset height1 = (Img_height/Img_width) * 500>
	  	<cfset width1 = (Img_width/Img_height) * height1>
	  </cfif>
     
</cfif>
    
    <cfelse>
   <!--- No Thumbnail --->
                    
    </cfif>  
	</cfif>    



		<!--- ******** --->
		<cfif isImage1>

 <cfif #get_itemInfo.picture1# is not ""> 


<cfif img_width gt 500>
		

	
		 <br><img src="../../fullsize_thumbs/#picture1URL#" width=#width1# height=#height1# >


		<cfelseif  img_width is "">
<br><img src="../../fullsize_thumbs/#picture1URL#" width=500>

	<cfelse>
		<br><img src="../../fullsize_thumbs/#picture1URL#">

		</cfif>
		</cfif>
		</cfif>
		<!--- ******** --->




            <cfif isSound>
              <br><b>Sound:</b> <a href="#soundURL#">#soundURL#</a>
            </cfif>
          </td>


<td valign=top>
	  <br>
	  <table border=0 cellspacing=0 cellpadding=0 noshade width=130>
	  <tr>
	  <td width=125 valign=top align=left>
	  <table border=0 cellsapcing=2>
			<tr>
			<td>
			<cfif isImage>
              <br><img src="#pictureURL#" width=124 height=110>
            </cfif>
		    </td></tr>
			<tr><td>
		<cfif isImage1>
		
		 <a href="javascript:winOpen1()"><img src="../../fullsize_thumbs/#picture1URL#" width=124 height=110 border=0></a>
		
		</cfif>
		</td></tr>
		<tr><td>
		<cfif isImage2>
		
		 <a href="javascript:winOpen2()"><img src="../../fullsize_thumbs1/#picture2URL#" width=124 height=110 border=0></a>
		
		</cfif>
		</td></tr>
		<tr><td>
		<cfif  isImage3>
		
		 <a href="javascript:winOpen3()"><img src="../../fullsize_thumbs2/#picture3URL#" width=124 height=110 border=0></a>
		
		</cfif>
		</td></tr>
		<tr><td>
		<cfif  isImage4>
		
		 <a href="javascript:winOpen4()"><img src="../../fullsize_thumbs3/#picture4URL#" width=124 height=110 border=0></a>
		
		</cfif>
		</td></tr>
</table>
</td></tr>
</table>

</td>
</tr>

      </table>
     
      <a name="BID">
      <br>
      
      <!--- if auction still open for bidding --->
      <cfif hAuctionComplete.bComplete IS 0>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td bgcolor=#heading_color# align="center" style="color:#heading_fcolor#; font-family:#heading_font#; font-size:12pt">
                <b>Make an Offer</b>
            </td>
          </tr>
        </table><br>
        <!--- display bidding info --->
		<table border="3"><tr><td>
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td valign=top align=center colspan=4>
              #Trim(get_ItemInfo.title)# (Item ###get_ItemInfo.itemnum#)
              <br>
              <br>
            </td>
          </tr>
          <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
            <tr>
              <td></td>
              <td align=left>
                <font size=2>
                  Current Offer
                </font>
              </td>
              <td align=right>
			  
                #bid_currently#  #Trim(getCurrency.type)#
              </td>
              <td></td>
            </tr>
            <tr>
              <td></td>
              <td align=left>
                <font size=2>
                  Offer Increment
                </font>
              </td>
              <td align=right>
                #bidIncrement# #Trim(getCurrency.type)#
              </td>
              <td></td>
            </tr>
          </cfif>
          <tr>
            <td width=180></td>
            <td width=140 align=left>
              <font size=2>
                <b>Maximum Offer</b>
              </font>
            </td>
            <td width=140 align=right>
              <b>#maximumBid# #Trim(getCurrency.type)#</b>
            </td>
            <td width=180></td>
          </tr>
          <!--- <tr>
            <td valign=top colspan=4>
              <font size=2>
                <br>
                <b>Registration Required.</b>  You must be a registered user in order to 
                make an offer.  <a href="#VAROOT#/registration/index.cfm">Click here</a> to find 
                out how to become a registered user.
              </font>
            </td>
          </tr> --->
        </table>
        <!--- display bidding form --->
        <form name="bidForm" action="#VAROOT#/bid/index.cfm" method="POST">
          <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
            <!--- <tr>
              <td width=220>
                <b>User ID</b> or <b>Nickname</b><br>
                <input type=text name="nickname" value="#userNickname#" size=20>
              </td>
              <td width=220>
                <b>Password</b> (<a href="#VAROOT#/registration/findpassword.cfm">forgotten it?</a>)<br>
                <input type=password name="password" value="" size=20>
              </td>
              <td width=200></td>
            </tr> --->
			<input type=hidden name="nickname" value="" size=20>
			<input type=hidden name="password" value="" size=20>
            <tr>
              <td colspan=2>
                <br>
                <!--- quantity if dutch or yankee --->
                <cfif get_ItemInfo.auction_type IS "D" OR get_ItemInfo.auction_type IS "Y">
                  <b>Quantity</b> you are bidding for.<br>
                  <input type=text name="quantity" value="1" size=10><br>
                  <input type=hidden name="bidType" value="REGULAR">
                  <br>
                </cfif>









                <!--- bid type if not dutch or yankee --->
                <cfif get_ItemInfo.auction_type IS "E" OR get_ItemInfo.auction_type IS "V">
                  <b><a href="#VAROOT#/help/bidtypes.cfm">Offer type</a>.</b><br>
                  <select name="bidType">
                    <option value="REGULAR"<cfif defBidType IS "REGULAR"> selected</cfif>>Regular Offer</option>
                    <option value="PROXY"<cfif defBidType IS "PROXY"> selected</cfif>>Auto Offer</option>
                  </select><br>
                  <input type=hidden name="quantity" value="1">
                  <br>
                </cfif>
                <!--- Offer --->
                <b>Your Offer.</b><br>
                <input type=text name="bid" value="#REReplace(maximumBid, "[^0123456789.]", "", "ALL")#" size=10> (The amount you are offering <cfif get_ItemInfo.auction_type IS "D" OR get_ItemInfo.auction_type IS "Y"><b>each</b><cfelse>this</cfif> item
                or service for.)<br>
				<input type=hidden name="requiredBid" value="#REReplace(maximumBid, "[^0123456789.]", "", "ALL")#" size=10>
				<cfset bidIncrement = IIf(get_ItemInfo.increment, "get_ItemInfo.increment_valu", "get_ItemInfo.increment_valu")>
				<cfset bidIncrement = numberFormat(bidIncrement,numbermask)>
                Your bid must be a multiple of #bidIncrement# #Trim(getCurrency.type)#.
                <br>
                Please enter only numerals and the decimal point.  Do not include 
                currency symbols such as a dollar sign ('$') or commas (',').  Unless 
                otherwise noted, offers are in #Trim(getCurrency.type)# (#currencyName#).<br>
                <br>
                <cfif enableSSL>
                  <b>Use <a href="https://#CGI.SERVER_NAME##VAROOT#/listings/details/index.cfm?itemnum=#get_ItemInfo.itemnum#">Secure Sockets Layer</a></b><br>
                  &nbsp;&nbsp;This form is unsecure.  Click the preceeding link if you 
                  would like to use <a href="#VAROOT#/help/ssl.cfm">Secure&nbsp;Sockets&nbsp;Layer</a> 
                  to place an offer on this item.<br>
                  <br>
                </cfif>
                <b>Binding contract.</b><br>
                &nbsp;&nbsp;Placing a offer could be a binding contract in some state and provinces. 
                Do not make an offer unless you intend to sell this item or service at the amount you are offering.<br>
                <br>
					 <cfif auction_mode is 0>
                <!--- auction type --->
                <cfif get_ItemInfo.auction_type IS "E">
                  <b>This is an <a href="#VAROOT#/help/auctiontypes.cfm##ENGLISH">English auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  English auctions before offering.<br>
                <cfelseif get_ItemInfo.auction_type IS "V">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##VICKREY">Vickrey auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Vickrey auctions before bidding.<br>
                <cfelseif get_ItemInfo.auction_type IS "D">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##DUTCH">Dutch auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Dutch auctions before bidding.<br>
                <cfelseif get_ItemInfo.auction_type IS "Y">
                  <b>This is a <a href="#VAROOT#/help/auctiontypes.cfm##YANKEE">Yankee auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Yankee auctions before bidding.<br>
                </cfif>
					 
					 <cfelse>
					 <!--- This code is for Reverse Auction links --->
					 <cfif get_ItemInfo.auction_type IS "E">
                  <b>This is a <a href="#VAROOT#/help/rev_auctiontypes.cfm##ENGLISH">&nbsp;Reverse English auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  English auctions before offering.<br>
                <cfelseif get_ItemInfo.auction_type IS "V">
                  <b>This is a <a href="#VAROOT#/help/rev_auctiontypes.cfm##VICKREY">&nbsp;Reverse Vickrey auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Vickrey auctions before offering.<br>
                <cfelseif get_ItemInfo.auction_type IS "D">
                  <b>This is a <a href="#VAROOT#/help/rev_auctiontypes.cfm##DUTCH">&nbsp;Reverse Dutch auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Dutch auctions before offering.<br>
                <cfelseif get_ItemInfo.auction_type IS "Y">
                  <b>This is a <a href="#VAROOT#/help/rev_auctiontypes.cfm##YANKEE">&nbsp;Reverse Yankee auction</a>.</b><br>
                  &nbsp;&nbsp;Please refer to the preceeding link for the rules governing 
                  Yankee auctions before offering.<br>
                </cfif></cfif>
					 
                &nbsp;&nbsp;If you have made an offer on this item before, your new offer 
                must be greater than your previous offer.<br>
                <br>
                <input type=submit value="Review Offer" name="reviewBid"><br>
                <input type=hidden name="itemnum" value="#get_ItemInfo.itemnum#">
                <br>
              </td>
              <td></td>
            </tr>
          </table>
		  </td></tr></table>



<cfif isdefined("session.user_id") and session.user_id neq "" and isdefined("session.password") and session.password neq "">

<cfquery name="getuser" datasource="#datasource#">
select nickname, password from users where user_id = #session.user_id# and password='#session.password#'
</cfquery>

<input type=hidden name="password" value="#session.password#">
<input type=hidden name="nickname" value="#getuser.nickname#">
</cfif>
        </form>
      </cfif>
      
      <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td>
            <!--- include menu bar --->
            <center>
              <br>
              <br>
            </center>
          </td>
        </tr>
      </table>
      <br>
      <br>
      <!--- if iescrow enabled, display --->
      <!---<cfif hIEscrow.bEnabled>
        
        <table border=0 cellspacing=0 cellpadding=0 noshade width=640>
          <tr>
            <td valign=bottom><a href="#hIEscrowIcons.sIEHomeURL#"><img src="#hIEscrowIcons.sURL##hIEscrowIcons.sCurrentOption#" border=0></a></td>
            <td align=left valign=bottom>
              <font size=2>
                For the convenience of credit card payment and the opportunity<br>to inspect 
                your purchase, consider safe, easy-to-use escrow services.
              </font>
            </td>
          </tr>
        </table>
        <br>
      </cfif> 

--->
      <table border=0 cellspacing=0 cellpadding=0 noshade width=800>
        <tr>
          <td align=left valign=top>
                        <hr size=1 color=#heading_color# width=100%>
            <font size=2>
               <cfinclude template="../../includes/copyrights.cfm">
               <br>
               <br>
               <br>
            </font>
          </td>
        </tr>
      </table>
    </center>
   	</table> 
  </body>
</html>
</cfoutput>
</cfif>
