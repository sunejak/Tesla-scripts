# Tesla-scripts

This is really small collection of useful command line scripts towards your Tesla model S.

Depends on <b>curl</b> for HTTP requests.

Depends on <b>jq</b> for pretty printing of JSON data.

Inspired by https://timdorr.docs.apiary.io/

You also need the keys for the Oauth API in a file named keys.txt, defining the variables CLIENT_ID and CLIENT_SECRET

 1. Get data from your model S, ./sh/data_request.sh email password command
  <ul>
  <li>Where command is:
   <ul>
   <li>vehicle_state</li> 
   <li>climate_state</li> 
   <li>charge_state</li>
   </ul>
 </li>
  </ul>

 2. Send commands to your model S, ./sh/send_command.sh email password command
  <ul>
  <li>Where command is:
   <ul>
    <li>auto_conditioning_start</li> 
    <li>honk_horn</li>
        </ul>
 </li>
  </ul>
