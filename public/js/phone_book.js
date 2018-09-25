window.fbAsyncInit = function() {
    FB.init({
      appId      : '291516238119557', // Set YOUR APP ID
      channelUrl : 'http://hayageek.com/examples/oauth/facebook/oauth-javascript/channel.html', // Channel File
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true,  // parse XFBML
      version    : 'v2.4',
      oauth      : true
    });

    FB.Event.subscribe('auth.authResponseChange', function(response) 
    {
     if (response.status === 'connected')

    {
       
        console.log("<br>Connected to Facebook");
        //SUCCESS
        FB.api('/me', { locale: 'tr_TR', fields: 'name, email, birthday, hometown' },
          function(response) {
            console.log(response.name);
            document.getElementById("fbname").innerHTML = response.name
            console.log(response.email);
            console.log(response.birthday);
            console.log(response.hometown);
          }
        );

    }    
    else if (response.status === 'not_authorized') 
    {
        console.log("Failed to Connect");

        //FAILED
    } else 
    {
        console.log("Logged Out");

        //UNKNOWN ERROR
    }
    }); 

    };

    function logIn() {
      window.location.replace("http://localhost:4567/contacts_page");
    }