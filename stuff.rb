# // FB.Event.subscribe('xfbml.render', finished_rendering);
# // </script>
# // <div id="spinner"
# //     style="
# //         background: #4267b2;
# //         border-radius: 5px;
# //         color: white;
# //         height: 40px;
# //         text-align: center;
# //         width: 250px;">
# //     Loading
# //     <div
# //     class="fb-login-button"
# //     data-max-rows="1"
# //     data-size="large"
# //     data-button-type="continue_with"
# //     data-use-continue-as="true"
# //     ></div>
# // </div>


# // <div
# //     class="fb-login-button"
# //     data-max-rows="1"
# //     data-size="<medium, large>"
# //     data-button-type="continue_with"
# //     data-width="<100% or px>"
# //     data-scope="<comma separated list of permissions, e.g. public_profile, email>"
# // ></div>
# // }

# // FB.getLoginStatus(function(response) {
# //     statusChangeCallback(response);
# // });


# // {
# //     status: 'connected',
# //     authResponse: {
# //         accessToken: '...',
# //         expiresIn:'...',
# //         signedRequest:'...',
# //         userID:'...'
# //     }
# // }



# <div
#     class="fb-login-button"
#     data-max-rows="1"
#     data-size="medium"
#     data-button-type="continue_with"
#     data-width="100%"
#     data-scope="name, email"
# ></div>

# var finished_rendering = function() {
#   console.log("finished rendering plugins");
#   var spinner = document.getElementById("spinner");
#   spinner.removeAttribute("style");
#   spinner.removeChild(spinner.childNodes[0]);
# }

# (function(d, s, id) {
#   var js, fjs = d.getElementsByTagName(s)[0];
#   if (d.getElementById(id)) return;
#   js = d.createElement(s); js.id = id;
#   js.src = "//connect.facebook.net/tr_TR/sdk.js#xfbml=1&version=v2.4&appId=291516238119557";
#   fjs.parentNode.insertBefore(js, fjs);
# }(document, 'script', 'facebook-jssdk'));