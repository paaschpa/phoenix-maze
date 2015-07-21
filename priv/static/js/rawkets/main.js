$(function() {
	var game;
	
    function guid() {
            var ret = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
                return v.toString(16);});
            return ret;
    }
        
	/**
	 * Initialises client-side functionality
	 */
	function init() {
		// WebSockets supported
		if ("WebSocket" in window) {
			var welcome = $("#welcome");
			
			// Player isn't authenticated on Twitter
			if (window.TWITTER_AUTHENTICATE_URL != undefined && TWITTER_AUTHENTICATE_URL != null) {
				var twitter = $("<a id='twitterSignIn' href='"+TWITTER_AUTHENTICATE_URL+"'></a>");
				twitter.appendTo("#welcome");
			};
			
			welcome.fadeIn();
			
			// Player is apparently authenticated on Twitter
			if (TWITTER_ACCESS_TOKEN != null && TWITTER_ACCESS_TOKEN_SECRET != null) {
				// Perform check to see if authentication is working
				
				welcome.fadeOut();
				
				// Manual sound setup – move this at a later date
				var flashvars = {};
				var params = {allowscriptaccess: "always"};
				swfobject.embedSWF("/js/rawkets/style/Sounds.swf", "soundContainer", "0", "0", "9.0.0", "", flashvars, params);
				
                var playerId = guid().slice(0,6);
				game = new Game(playerId);

				$("#attribution, #ping").fadeTo(500, 0.1).mouseover(function() {
					$(this).stop().fadeTo(500, 1);
				}).mouseout(function() {
					$(this).stop().fadeTo(500, 0.1);
				});

				initListeners();
			};
		// WebSockets not supported
		} else {
			$("#mask, #support").fadeIn();
		};
	};
	
	/**
	 * Initialises environmental event listeners
	 */	
	function initListeners() {
		$(window).bind("resize", {self: game}, game.resizeCanvas)
				 // Horrible passing of game object due to event closure
				 .bind("keydown", {self: game}, game.keyDown)
				 .bind("keyup", {self: game}, game.keyUp);
	};
	
	// Initialise client-side functionality
	init();
});
