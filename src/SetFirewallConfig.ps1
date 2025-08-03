#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Get-WiresharkFilters.ps1                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

# Example:
# Get-WiresharkFilters -ProcessName '0010_Hello_World' -Verbose

function Set-FirewallConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "preset")]
        [ValidateSet('low', 'medium', 'maximum', 'custom')]
        [string]$firewallLevel = "medium", # Accepts 
        [Parameter(Mandatory = $False, ParameterSetName = "custom")]
        [switch]$block_http,
        [Parameter(Mandatory = $False, ParameterSetName = "custom")]
        [switch]$block_icmp,
        [Parameter(Mandatory = $False, ParameterSetName = "custom")]
        [switch]$block_multicast,
        [Parameter(Mandatory = $False, ParameterSetName = "custom")]
        [switch]$block_peer,
        [Parameter(Mandatory = $False, ParameterSetName = "custom")]
        [switch]$block_ident
    )
    try {
        [int]$ProcessToLookup = 0


        # Convert the firewall level to match expected format in the request
        switch ($firewallLevel.ToLower()) {
            "low" { $firewallLevel = "low" }
            "medium" { $firewallLevel = "medium" }
            "maximum" { $firewallLevel = "high" }
            "custom" { $firewallLevel = "custom" }
            default { $firewallLevel = "None" }
        }

        # Determine if blocking switches are enabled or disabled
        $blockHttp = if ($block_http) { "Enabled" } else { "Disabled" }
        $blockIcmp = if ($block_icmp) { "Enabled" } else { "Disabled" }
        $blockMulticast = if ($block_multicast) { "Enabled" } else { "Disabled" }
        $blockPeer = if ($block_peer) { "Enabled" } else { "Disabled" }
        $blockIdent = if ($block_ident) { "Enabled" } else { "Disabled" }

        # Build the configuration JSON string
        $firewallCfg = @{
            firewallLevel = $firewallLevel
            block_http = $blockHttp
            block_icmp = $blockIcmp
            block_multicast = $blockMulticast
            block_peer = $blockPeer
            block_ident = $blockIdent
        } | ConvertTo-Json -Depth 1

        # CSRF token (replace with actual token if required)
        $csrfToken = "26s2gi8iqi"

        # Prepare the request body
        $body = @{
            configInfo = $firewallCfg
            csrfp_token = $csrfToken
        }

        Write-Verbose "Firewall configuration $firewallCfg"
        # Send the POST request
        try {

            $response = Invoke-WebRequest -Uri "http://10.0.0.1/actionHandler/ajaxSet_firewall_config.jst" -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
            Write-Host "Firewall configuration updated successfully."
            return $response
        }
        catch {
            Write-Host "Failed to update firewall configuration: $_"
        }
    } catch {
        Write-Host "`n$Message"
    }
}



<#


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
    <title>Helix</title>
    <!--CSS-->
    <input type="hidden" name="loc" id="loc" value="false">
    <link rel="stylesheet" type="text/css" media="screen" href="./cmn/css/common-min.css" />
    <!--[if IE 6]>
    <link rel="stylesheet" type="text/css" href="./cmn/css/ie6-min.css" />
    <![endif]-->
    <!--[if IE 7]>
    <link rel="stylesheet" type="text/css" href="./cmn/css/ie7-min.css" />
    <![endif]-->
    <link rel="stylesheet" type="text/css" media="print" href="./cmn/css/print.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="./cmn/css/lib/jquery.radioswitch.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="./cmn/css/lib/progressBar.css" />
    <!--Character Encoding-->
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <meta name="robots" content="noindex,nofollow">
    <script type="text/javascript" src="./cmn/js/lib/jquery-3.4.1.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery-migrate-1.2.1.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.validate.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.alerts.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.ciscoExt.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.highContrastDetect.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.radioswitch.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/jquery.virtualDialog.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/bootstrap.min.js"></script>
    <script type="text/javascript" src="./cmn/js/lib/bootstrap-waitingfor.js"></script>
    <!-- update the version of utilityFunctions.js if any changes is made to this js file otherwise browser will take the old js file from the cache memory -->
    <script type="text/javascript" src="./cmn/js/utilityFunctions.js?v=1"></script>
    <script type="text/javascript" src="./cmn/js/gateway.js"></script>
 <script src="./locale/CLDRPluralRuleParser.js"></script>
  <script src="./locale/jquery.i18n.js"></script>
  <script src="./locale/jquery.i18n.messagestore.js"></script>
  <script src="./locale/jquery.i18n.fallbacks.js"></script>
  <script src="./locale/jquery.i18n.language.js"></script>
  <script src="./locale/jquery.i18n.parser.js"></script>
  <script src="./locale/jquery.i18n.emitter.js"></script>
  <script src="./locale/jquery.i18n.emitter.bidi.js"></script>
   <script src="./locale/global.js"></script> <!-- add this -->
    <style>
    #div-skip-to {
        position:relative;
        left: 150px;
        top: -300px;
    }
    #div-skip-to a {
        position: absolute;
        top: 0;
    }
    #div-skip-to a:active, #div-skip-to a:focus {
        top: 300px;
        color: #0000FF;     
        /*background-color: #b3d4fc;*/
    }
    table .delete, table .edit{
                width:60px;
        }
    </style>    
<script type="text/javascript">
function alertLoc(msg){
        var locale=$('#loc').val();
        //locale for independent messages that cannot be binded to html elements
        $.i18n().locale = locale;
        $.i18n().load( {
                        it: {
                                "Please Login First!":"Per procedere, effettua l'accesso",
                "Access Denied!":"Accesso Negato"
                        }
                });
        alert($.i18n(msg));
}
</script>
</head>
<script type="text/javascript">
function isIE() {
  ua = navigator.userAgent;
  /* MSIE used to detect old browsers and Trident used to newer ones*/
  var is_ie = ua.indexOf("MSIE ") > -1 || ua.indexOf("Trident/") > -1;
  
  return is_ie; 
}
    $(document).ready(function() {
    var locale=$('#locale').val();
    //locale for independent messages that cannot be binded to html elements
    $.i18n().locale = locale;
    $.i18n().load( {
        it: {
                "Bridge Mode changes will be fully applied in": "Le modifiche sulla Bridge Mode saranno applicate tra",
                " seconds, please be patient...": " secondi, attendi...",
        " Security": "Livello sicurezza:",
        "delete this service for ":"elimina questo servizio per ",
        "remove computer named ":"rimuovi dispositivo chiamato ",
        "delete this Port Forwarding service for ":"elimina questo servizio di Port Forwarding per ",
        "delete port Triggering for ":"elimina port triggering per ",
        "Low":"Minima",
        "Enable Logging":"Attiva registrazione",
                "Disable Logging":"Disattiva registrazione",
        "Please input a valid URL, start with 'http://' or 'https://'":"Inserire un URL valido, iniziare con 'http://' o 'https://'.",
        "Medium":"Tipica",
        "Custom":"Personalizzata",
        "Firewall is set to Custom":"Il livello di sicurezza del firewall è impostato su Personalizzata",
        "Firewall is set to None":"Il livello di sicurezza del firewall è impostato su Nessuna",
        "None":"Nessuna",
        "Inactive":"Non attivo",
        "Error":"Errore",
        "Error_Internal":"Errore Interno",
        "Active":"Attivo",
        "Status:":"Stato:",
        "High":"Massima",
        "Traceroute Tool":"Strumento Traceroute",
        "Status: Unconnected-":"Stato: Disconnesso-",
                "no devices":"nessun dispositivo",
                "devices connected":"dispositivi connessi",
        "WARNING: Enabling Remote Management will expose your Gateway GUI to Internet. Your Gateway will only be protected by your logon password. Are you sure you want to continue?":"L'attivazione della gestione remota renderà accessibile la GUI del tuo Sky Wifi Hub da Internet. Il tuo Sky Wifi Hub sarà protetto solo dalla password di accesso. Vuoi continuare?",
        "Check telephony line status, please wait...":"Controllo dello stato della linea telefonica in corso, attendere...",
                "Firewall is set to Low":"Il livello di sicurezza del firewall è impostato su Minima",
        "Changes saved successfully. <br/> Please login with the new password.":"Modifiche salvate correttamente. <br/> Accedi con la nuova password.",
                "Firewall is set to Medium":"Il livello di sicurezza del firewall è impostato su Tipica",
                "Firewall is set to High":"Il livello di sicurezza del firewall è impostato su Massima ",
                "Firewall is set to Custom":"Il livello di sicurezza del firewall è impostato su Personalizzata ",
                "Status: Connected-":"Stato: Connesso-",
        "Enabling Bridge Mode will disable the Wi-Fi router functionality of your ":"Abilitando la Bridge Mode si disabiliterà la funzionalità Wi-Fi del Gateway ",
        " Gateway and turn off your existing private Wi-Fi network. If you have ":" e si spegnerà la rete Wi-Fi privata esistente. Se si dispone di Pod ",
        " Pods, the Gateway cannot be in bridge mode since the Pods require using the ":" , il Gateway non può essere in modalità bridge poiché i Pod richiedono l'utilizzo del Gate ",
        " Gateway as your WiFi router. In addition, you will not be able to access the ":" come router WiFi. Inoltre, non sarà possibile accedere all'esperienza ",
        " experience to manage your Pods or any other ":" per gestire i Pod o altre impostazioni ",
        " settings. Are you sure you want to continue?":". Continuare?",
        "Enabling Bridge Mode will disable the Wi-Fi router functionality of your Gateway and turn off your existing private Wi-Fi network. If you have Pods, the Gateway cannot be in bridge mode since the Pods require using the Gateway as your WiFi router. In addition, you will not be able to access the experience to manage your Pods or any other settings. Are you sure you want to continue?":"Abilitando la Bridge Mode si disabiliterà la funzionalità wifi del tuo Sky Wifi Hub e si spegnerà la rete wifi privata esistente. Se si dispone di Pod, il tuo Sky Wifi Hub non può essere in modalità bridge poiché i Pod richiedono l&#39;utilizzo del tuo Sky Wifi Hub come router wifi. Inoltre, non sarà possibile accedere all&#39;esperienza per gestire i Pod o altre impostazioni. Continuare?",
        "WARNING:":"ATTENZIONE:",
        "This may take several seconds":"Questa operazione potrebbe richiedere alcuni secondi",
        "This may take several seconds...":"L'operazione potrebbe richiedere alcuni secondi...",
        "This may take several seconds.":"Questa operazione potrebbe richiedere alcuni secondi.",
        "<b>There are currently no Call Signal Logs</b>":"<b>Attualmente non ci sono log di segnale chiamata</b>",
        "Call Signal logs":"Log di segnale chiamata",
        "This table shows Call Signal logs":"Questa tabella mostra i Log di segnale chiamata",
        "Online Devices":"Dispositivi connessi",
        "Offline Devices":"Dispositivi disconnessi",
        "more":"espandi",
        "less":"riduci",
        "Enable":"Attiva",
        "Disable":"Disattiva",
        "Add":"Aggiungi",
        "Reserved IP Address is not in valid range:":"L&#39;indirizzo IP riservato non è in un intervallo valido:",
        "Are you sure you want to ":"Sei sicuro di ",
        "Are you sure?":"Sei sicuro?",
        "Are You sure?":"Sei sicuro?",
        "Host Name:":"Nome Host:",
        "Special characters are not allowed, Only hyphen(-), letters and Numbers are allowed.":"Non sono ammessi caratteri speciali, puoi inserire solo lettere e numeri.",
        "Reserved IP Address is not in valid range:":"L&#39;indirizzo IP riservato non è in un intervallo valido:",
        "Only hexadecimal characters are valid. Acceptable characters are ABCDEF0123456789.":"Sono validi solo i caratteri esadecimali. I caratteri accettabili sono ABCDEF012323456789.",
        "DMZ v4 Host address is beyond the valid range.":"L'indirizzo host DMZ v4 è al di fuori dell&#39;intervallo valido.",
        "Enable DMZ":"Attiva DMZ",
        "Disable DMZ":"Disattiva DMZ",
        "DMZ v4 Host IP is not in valid range:":"IP host DMZ v4 non è nell’intervallo valido:",
        "Enable Dynamic DNS":"Attiva DNS dinamico",
        "Disable Dynamic DNS":"Disattiva DNS dinamico",
        "Spaces are not allowed":"Non sono ammessi spazi.",
        "Special characters are not allowed.":"Non sono ammessi caratteri speciali.",
        "Remove":"Rimuovi ",
        "You are trying to disable the firewall. It is a security risk. Are you sure you want to continue?":"Stai cercando di disattivare il firewall. Questo rappresenta un rischio per la tua sicurezza. Continuare?",
        "The firewall security level is currently set to":"Il livello di sicurezza del firewall è attualmente impostato su",
        "Are you sure you want to change to default settings?":"Passare alle impostazioni predefinite?",
        "Reset Default Firewall Settings":"Ripristina impostazioni firewall predefinite",
        "Please enter a valid IP address.":"Inserire un indirizzo IP valido.",
        "Please enter a port number in range 1~65535.":"Inserire un numero di porta nell&#39;intervallo 1~65535.",
        "Please enter a value more than or equal to Start Public Port.":"Inserire un valore maggiore o uguale a quello della Porta pubblica di partenza.",
        "Press <b>OK</b> to continue session. Otherwise you will be logged out in":"Premere <b>OK</b> per continuare la sessione. In caso contrario, la disconnessione avverrà tra",
        "seconds!":"secondi",
        "You missed 1 field. It has been highlighted":"Hai saltato 1 campo. È stato evidenziato",
        "You missed":"Hai saltato",
        "fields. They have been highlighted":"campi. Sono stati evidenziati",
        "Username cannot be blank. Please enter a valid username.":"Il nome utente non può essere vuoto. Inserisci un nome utente valido.",
        "Password cannot be blank. Please enter a valid password.":"La password non può essere vuota. Inserisci una password valida.",
        "Password must be at least 3 characters.":"La password deve contenere almeno 3 caratteri.",
        "You are being logged out due to inactivity!":"Disconnessione programmata per inattività",
        "DHCP Beginning address is beyond the valid range.":"L&#39;indirizzo di inizio DHCP è oltre l&#39;intervallo valido.",
        "DHCP Ending address is beyond the valid range.":"L&#39;indirizzo di fine DHCP è oltre l&#39;intervallo valido.",
        "Are you sure you want to change LAN IPv4 to default settings?":"Passare LAN IPv4 alle impostazioni predefinite?",
        "Reset Default IPv4 Settings":"Ripristina impostazioni IPv4 predefinite",
        "This may need you to relogin with new Gateway IP address":"Potrebbe essere necessario accedere nuovamente con il nuovo indirizzo IP del tuo Sky Wifi Hub",
        "Please be patient...":"Attendi...",
        "Gateway IP is not in valid private IP range":"L&#39;IP del tuo Sky Wifi Hub non è in un intervallo IP privato valido",
        "Are you sure you want to change LAN IPv6 to default settings?":"Passare LAN IPv6 alle impostazioni predefinite?",
        "Reset Default IPv6 Settings":"Ripristina impostazioni IPv6 predefinite",
        "Enable managed devices":"Attiva blocco dispositivi",
        "Disable managed devices":"Disattiva blocco dispositivi",
        "Select allow all":"Seleziona consenti tutto",
        "Select block all":"Seleziona blocca tutto",
        "Allow All":"Consenti tutto",
        "Block All":"Blocca tutto",
        "Are you sure you want to delete this device?":"Sei sicuro di voler rimuovere questo dispositivo?",
        "Select always allow":"Seleziona consenti sempre",
        "Unselect always allow":"Deseleziona consenti sempre",
        "Conflicting Block MAC Address:":"Indirizzo MAC di blocco in conflitto:",
        "Add/Edit Device to be Blocked Alert:":"Aggiungi/Modifica Avviso dispositivo da bloccare:",
        "Select always block":"Seleziona blocca sempre",
        "Unselect always block":"Deseleziona blocca sempre",
        "Enable managed services":"Attiva blocco servizi",
        "Disable managed services":"Disattiva blocco servizi",
        "Select trust":"Imposta come Autorizzato",
        "Select untrust":"Imposta come Non autorizzato",
        "Are you sure you want to delete this service?":"Sei sicuro di voler eliminare questo servizio?",
        "Please enter a value more than or equal to Start Port.":"Inserire un valore maggiore o uguale alla Porta di partenza.",
        "Duplicate Service Name:":"Nome servizio duplicato:",
        "Conflicting Service Block Rule!":"Regola di blocco servizio in conflitto",
        "Add/Edit Service to be Blocked Alert:":"Aggiungi/Modifica avviso sul servizio da bloccare:",
        "Enable managed sites":"Attiva blocco siti web",
        "Disable managed sites":"Disattiva blocco siti web",
        "Letters and Numbers only. Case sensitive.":"Utilizza solo lettere e numeri. Sensibile alle maiuscole e minuscole.",
        "Enable MoCA":"Attiva MoCA",
        "Disable MoCA":"Disattiva MoCA",
        "Waiting for backend to be fully executed, please be patient...":"In attesa che il backend venga eseguito completamente. Attendi...",
        "Status:":"Stato:",
        "Phone is Off-Hook, do you want to start the test anyway?":"Il telefono è scollegato, avviare comunque il test?",
        "This action may take more than one minute. Do you want to continue?":"Questa azione può richiedere più di un minuto. Continuare?",
        "<b>There are currently no SIP Packet Logs</b>":"<b>Attualmente non ci sono log pacchetto SIP</b>",
        "Please enter a valid Hostname.":"Inserire un nome host valido.",
        "Close":"Chiudi",
        "Enable port forwarding":"Attiva port forwarding",
        "Disable port forwarding":"Disattiva port forwarding",
        "Choose or input a service name":"Scegliere o inserire il nome di un servizio",
        "Please input a service name !":"Inserire un nome di servizio",
        "Please enter a port number less than 65536.":"Inserire un numero di porta inferiore a 65536.",
        "Please enter a service name.":"Inserire un nome di servizio.",
        "Server IPv6 addr is not in valid range":"Indir. server IPv6 non è in un intervallo valido",
        "Select from below Connected Devices:":"Seleziona un dispositivo tra quelli connessi, elencati sotto:",
        "Enable port triggering":"Attiva triggering porta",
        "Disable port triggering":"Disattiva triggering porta",
        "Please enter a value more than or equal to Trigger Port From.":"Immettere un valore maggiore o uguale a Porta trigger da.",
        "Please enter a value more than or equal to Target Port From.":"Immettere un valore maggiore o uguale a Porta di destinazione da.",
        "Please enter a value more than or equal to Trigger Starting Port.":"Inserire un valore maggiore o uguale a Porta di partenza trigger.",
        "Please enter a value more than or equal to Target Starting Port.":"Inserire un valore maggiore o uguale a Porta di partenza destinazione.",
        "Are you sure to clear call signal log?":"Cancellare il registro delle chiamate?",
        "Are you sure to clear DSX log?":"Cancellare il registro DSX?",
        "Confirm":"Attenzione",
        "Enable HTTP":"Attiva HTTP",
        "Disable HTTP":"Disattiva HTTP",
        "WARNING: Enabling Remote Management will expose your Gateway GUI to Internet. Your Gateway will only be protected by your logon password. Are you sure you want to continue?":"L'attivazione della gestione remota renderà accessibile la GUI del tuo Sky Wifi Hub da Internet. Il tuo Sky Wifi Hub sarà protetto solo dalla password di accesso. Vuoi continuare?",
        "Confirm:":"Conferma:",
        "Enable HTTPS":"Attiva HTTPS",
        "Disable HTTPS":"Disattiva HTTPS",
        "Please enter valid IP address (Note: Start IP must be less than end IP !)":"Inserire un indirizzo IP valido (Nota: l&#39;IP iniziale deve essere inferiore all&#39;IP finale)",
        "Please enter a port number 1025 ~ 65535.":"Inserire un numero di porta tra 1025 ~ 65535.",
        "Please enter a different port.":"Inserire una porta differente.",
        "This will take several seconds!":"L'operazione richiederà alcuni secondi.",
        "<strong>WARNING:</strong> Gateway will be rebooted!<br/>Incoming/outgoing call and internet connection will be interrupted!":"<strong>ATTENZIONE:</strong> Il tuo Sky Wifi Hub sarà riavviato!<br/>Le chiamate in entrata/uscita e la connessione internet saranno interrotte.",
        "Phone is Off-Hook, do you want to proceed anyway?":"Il telefono è disconnesso, procedere comunque?",
        "<strong>WARNING:</strong> Wi-Fi will be unavailable for at least 90 seconds!":"<strong>ATTENZIONE:</strong> il wifi non sarà disponibile per almeno 90 secondi",
        "Please wait for rebooting ...":"Attendere il riavvio...",
        "Restarting Wi-Fi radios. This may take up to ":"Riavvio del wifi entro un massimo di ",
        "seconds...":"secondi...",
        "Ethernet Mode":"Modalità Ethernet",
        "Docsis Mode":"Modalità Docsis",
        "Please note that changing the configuration to Ethernet WAN requires connection of an Ethernet cable to a service provider gateway.":"La modifica della configurazione in WAN Ethernet richiede il collegamento di un cavo Ethernet al gateway.",
        "Scanning...":"Scansione in corso...",
        "Enable radio 2.4G":"Attiva wifi 2,4GHz",
        "Disable radio 2.4G":"Disattiva wifi 2,4GHz",
        "Enable radio 5G":"Attiva wifi 5GHz",
        "Disable radio 5G":"Disattiva wifi 5GHz",
        "Enable radio 6G":"Attiva wifi 6GHz",
        "Disable radio 6G":"Disattiva wifi 6GHz",
        "Enable WPS":"Attiva WPS",
        "Disable WPS":"Disattiva WPS",
        "Enable WPS PIN":"Attiva WPS PIN",
        "Disable WPS PIN":"Disattiva WPS PIN",
        "WARNING:<br/> Changing the Wi-Fi mode to '802.11 b/g/n' will significantly reduce the performance of your Wi-Fi network. This setting is required only if you have older 'b only' Wi-Fi devices in your network. All newer Wi-Fi devices support '802.11 g/n' mode. Are you sure you want to continue with the change?":"ATTENZIONE:<br/> cambiando la modalità wifi in '802.11 b/g/n' si ridurranno significativamente le prestazioni della rete wifi. Questa impostazione è necessaria solo se nella rete sono presenti dispositivi wifi 'b only' più vecchi. Tutti i dispositivi wifi più recenti supportano la modalità '802.11 g/n'. Continuare con la modifica?",
        "WARNING:<br/> You are selecting a Dynamic Frequency Selection (DFS) Channel (52-140). Some Wi-Fi devices do not support DFS channels in the 5 GHz band. For those devices that do not support DFS channels, the 5 GHz Wi-Fi Network Name (SSID) will not be displayed on the list of available networks. Do you wish to continue?":"ATTENZIONE:<br/> si sta selezionando un canale di selezione dinamica della frequenza (DFS) (52-140). Alcuni dispositivi wifi non supportano i canali DFS nella banda 5 GHz. Per i dispositivi che non supportano i canali DFS, il nome della rete wifi a 5 GHz (SSID) non verrà visualizzato nell&#39;elenco delle reti disponibili. Continuare?",
        "Please enter valid Device Name! \n Less than (<), Greater than (>), Ampersand (&), Double quote (\"), \n Single quote (') and Pipe (|) characters are not allowed.":"Inserire un nome dispositivo valido. Non sono consentiti caratteri come: \n Minore di (<), maggiore di (>), E commerciale (&), Virgolette doppie (\"), \n Virgolette singole (') e Barra dritta (|).",
        "Please enter device name!":"Inserisci il nome dispositivo",
        "Please enter valid MAC address! \n First byte must be even. \n Each character must be [0-9a-fA-F].":"Inserisci un indirizzo MAC valido. Il caratteri devono essere compresi tra [0-9;a-f;A-F].",
        "Are you sure you want to delete this entry from Wi-Fi Control List?":"Sei sicuro di voler eliminare questa voce dall&#39;elenco di controllo wifi?",
        "Are you sure you want to cancel WPS progress?":"Sei sicuro di voler eliminare questo avanzamento WPS?",
        "WPS progress cancelling...":"Eliminazione avanzamento WPS in corso....",
        "Band Steering History":"Cronologia Band Steering",
        "Wi-Fi Security Modes":"Modalità di sicurezza Wi-Fi",
        "Open networks do not have a password.":"Le reti aperte non hanno password.",
        "Open (risky)":"Aperta (rischioso)",
        "WEP  64 requires a  5 ASCII character or  10 hex character password. Hex means only the following characters can be used: ABCDEF0123456789.":"WEP 64 richiede una password di 5 caratteri ASCII o 10 caratteri esadecimali. Esadecimale significa che possono essere utilizzati solo i seguenti caratteri: ABCDEF012323456789.",
        "WEP 64 (risky)":"WEP 64 (rischioso)",
        "WEP 128 requires a 13 ASCII character or  26 hex character password. Hex means only the following characters can be used: ABCDEF0123456789.":"WEP 128 richiede una password di 13 caratteri ASCII o 26 caratteri esadecimali. Esadecimale significa che possono essere utilizzati solo i seguenti caratteri: ABCDEF012323456789.",
        "WEP 128 (risky)":"WEP 128 (rischioso)",
        "Enable radio":"Abilita Wi-Fi",
        "Disable radio":"Disabilita Wi-Fi",
         "WARNING:<br/> Disabling Broadcast Network Name (SSID) will disable Wi-Fi Protected Setup (WPS) functionality. Are you sure you want to change?":"ATTENZIONE:<br/> Disabilitando la trasmissione del nome della rete wifi (SSID) si disattiva la funzionalità Wifi Protected Setup (WPS). Vuoi continuare?",
        "WARNING:<br/>Changing the Security Mode to Open will disable Wi-Fi Protected Setup(WPS) functionality. Are you sure you want to change?":"ATTENZIONE:<br/> Modificando la modalità di sicurezza su Aperta si disattiva la funzionalità Wifi Protected Setup (WPS). Continuare?",
        "5 Ascii characters or 10 Hex digits.":"5 caratteri Ascii o 10 cifre esadecimali.",
        "13 Ascii characters or 26 Hex digits.":"13 caratteri Ascii o 26 cifre esadecimali.",
        "8 to 63 ASCII characters or a 64 hex character password.":"Da 8 a 63 caratteri ASCII o una password di 64 caratteri esadecimale.",
        "8 to 63 ASCII characters.":"Da 8 a 63 caratteri ASCII o una password di 64 caratteri esadecimali.",
        "1 to 32 ASCII characters.":"Da 1 a 32 caratteri ASCII",
        "SSID name cannot contain only spaces":"Il nome SSID non può contenere solo spazi",
        "Choose a different Network Name (SSID) than the one provided on your gateway.":"Scegliere un nome di rete Wi-Fi (SSID) diverso da quello presente sul retro del tuo Sky Wifi Hub.",
         "Choose a different Network Password than the one provided on your gateway.":"Scegliere una password di rete diversa da quella presente sul retro del tuo Sky Wifi Hub.",
        "Restoring Wi-Fi Settings is in progress...":"Ripristino impostazioni wifi in corso...",
         "WPA requires an 8-63 ASCII character or a 64 hex character password. Hex means only the following characters can be used: ABCDEF0123456789.":"WPA richiede una password di 8-63 caratteri ASCII o 64 caratteri esadecimali. Esadecimale significa che possono essere utilizzati solo i seguenti caratteri: ABCDEF012323456789.",
        "WPA requires an 8-63 ASCII character password or a 64 hex character password. Hex means only the following characters can be used: ABCDEF0123456789.":"WPA richiede una password di 8-63 caratteri ASCII o 64 caratteri esadecimali. Esadecimale significa che possono essere utilizzati solo i seguenti caratteri: ABCDEF012323456789.",
        "WPA2-PSK (AES)(Recommended)":"WPA2-PSK (AES) (consigliato)",
        "Warning: Please note that disabling the radio(s) might interrupt with your data and video services. It is recommended to keep the Wi-Fi radios ON for uninterrupted access to your subscribed services. To cancel these changes, choose cancel below.":"Attenzione: Se disattivi il wifi, la trasmissione di video e dati potrebbe essere interrotta. Ti consigliamo di mantenere il wifi attivo per continuare a usufruire del servizio. Per tornare indietro, premi Annulla.",
        "Cancel":"Annulla",
        "Enable UPnP":"Attiva UPnP",
        "Disable UPnP":"Disattiva UPnP",
        "Show More Security Mode Options":"Mostra più opzioni della modalità di sicurezza",
            "Yes":"Sì",
        "Alert":"Attenzione",
                "This IP address is reserved , please input again":"Questo IP è riservato, ripetere l'immissione",
                "Invalid IP":"IP Non valido",
        "Are You Sure?":"Sei sicuro?",
        "Conflict with other port123. Please use a different port!":"Conflitto con altra porta123. Si prega di utilizzare una porta diversa!",
        "Device Name should not exceed more than 63 characters":"Il nome del dispositivo non deve superare più di 63 caratteri"
    }
    } );
    
    $("table.data td").each(function() {
            if($(this).text().split("\n")[0].length > 25)
            {
                $(this).closest('table').css("table-layout", "fixed");
                $(this).css("word-wrap", "break-word");
            }
        });
    });

</script>


<body>
    <!--Main Container - Centers Everything-->
    <div id="container">
        <!--Header-->
        <div id="header">
            <p style="margin: 0">&nbsp;</p>
            <h2 id="logo" style="margin-top: 10px"><img src='cmn/syndication/img/logo_videotron.png' alt='Helix'  title='Helix' /></h2>
        </div> <!-- end #header -->
        <div id='div-skip-to' style="display: none;">
            <a id="skip-link" name="skip-link" href="#content">Skip to content</a>
        </div>
<input type="hidden" name="locale" id="locale" value="false">
        <!--Main Content-->
        <div id="main-content">

<!-- $Id: firewall_settings.jst 3158 2010-01-08 23:32:05Z slemoine $ -->
<div id="sub-header">
    
<!--dynamic generate user bar icon and tips-->

<script type="text/javascript">
setTimeout(function(){
    /*
    * get status when hover or tab focused one by one
    * but for screen reader we have to load all status once
    * below code can easily rollback
    */
    //update user bar
    var sessionCsrf= "c6sxyaaegj";
    if(document.cookie==""){
        sessionStorage.setItem("Csrfp_token",sessionCsrf);
    }
    var partner_id = 'videotron';
    $.ajax({
        type: "GET",
        url: "actionHandler/ajaxSet_userbar.jst",
        data: { configInfo: "noData" },
        dataType: "json",
        success: function(msg) {
            // theObj.find(".tooltip").html(msg.tips);
            for (var i=0; i<msg.tags.length; i++){
                if($.i18n().locale=="it"){
                                        var arr =[];
                                        arr=msg.tips[i].split('-');
                                        if(typeof(arr[1])!="undefined"){
                                                var arrnew =[];
                                                arrnew =arr[1].split(' ');
                                                var msgTooltip="";
                                                if(arrnew.length>2){
                                                        msgTooltip = $.i18n(arr[0]+'-')+"<br/>"+arrnew[0]+" "+$.i18n(arrnew[1]+' '+arrnew[2]);
                                                }else{
                                                        msgTooltip = $.i18n(arr[0]+'-')+"<br/>"+$.i18n(arrnew[0]+' '+arrnew[1]);
                                                }
                                                $("#"+msg.tags[i]).find(".tooltip").html(msgTooltip);
                                        }else{
                                                $("#"+msg.tags[i]).find(".tooltip").html($.i18n(arr[0]));
                                        }
                                }else{
                                        $("#"+msg.tags[i]).find(".tooltip").html(msg.tips[i].replace(/-/g, "<br/>"));
                                }
                $("#"+msg.tags[i]).removeClass("off");
                if(msg.mainStatus[i]=="false")$("#"+msg.tags[i]).addClass("off");
                if(msg.tags[i] === "sta_fire")
                {
                    if (!(("High"== msg.mainStatus[i]) || ("Medium"==msg.mainStatus[i])))
                    {
                        $("#"+msg.tags[i]).addClass("off");
                    }
                    $("#sta_fire a > label").text($.i18n(msg.mainStatus[i]+" Security"));
                }
            }
            //$sta_batt,$battery_class
            $("#sta_batt a").text(msg.mainStatus[4]+"%");
            $("#sta_batt > div > span").removeClass().addClass(msg.mainStatus[5]);
            if(partner_id.indexOf('sky-')===0){
                
                var ipv4_status = '';
                var ipv6_status = '';
                var map_mode = '';
                if((ipv6_status == 'up' || ipv4_status == 'up')&& map_mode =='MAPT'){
                    $('#sta_inet').removeClass('off');
                }
            }
        },
        error: function(){
            // does something
        }
    });
    //when clicked on this page, restart timer
    var jsInactTimeout = parseInt("840") * 1000;
    //if ("") jsInactTimeout = 5000;    // 5 seconds debug
    // var h_timer = setTimeout('alert("You are being logged out due to inactivity."); location.href="home_loggedout.jst";', jsInactTimeout);
    var h_timer = null;
    function timeOutFunction(){ 
        // console.log(h_timer);
        clearTimeout(h_timer);
        h_timer = setTimeout(function(){
            var cnt     = 60;
            var h_cntd  = setInterval(function(){
                $("#count_down").text(--cnt);
                // (1)stop counter when less than 0, (2)hide warning when achieved 0, (3)add another alert to block user action if network unreachable
                if (cnt<=0) {
                    clearInterval(h_cntd);
                    alertLocale("You have been logged out due to inactivity!");
                    location.href="home_loggedout.jst";
                }
            }, 1000);
            // use jAlert instead of alert, or it will not auto log out untill OK pressed!
            jAlert($.i18n('Press <b>OK</b> to continue session. Otherwise you will be logged out in')+' <span id="count_down" style="font-size: 200%; color: red;">'+ cnt+'</span> '+ $.i18n("seconds!")
            , $.i18n('You are being logged out due to inactivity!')
            , function(){
                clearInterval(h_cntd);
                $.ajax({
                type: "POST",
                });
            });
        }
        , jsInactTimeout);
    }
    $(document).click(function() {
        // do not handle click event when count-down show up
        if ($("#count_down").length > 0) {
            return;
        }

        timeOutFunction();
        
    }).trigger("click");

    const targetNode = document.querySelector('body');
    const config = { attributes: true, childList: true, subtree: true };

// Callback function to execute when mutations are observed
    const callback = function(mutationsList, observer) {
    if ($("#count_down").length > 0) {
        return; 
    }
    timeOutFunction();
    };

    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    observer.observe(targetNode, config);   

    // show pop-up info when focus
    $("#status a").focus(function() {
        $(this).mouseenter();
    });
    // disappear previous pop-up
    $("#status a").blur(function() {
        $(".tooltip").hide();
    });
}, 100);
</script>
<style>
#status a:link, #status a:visited {
    text-decoration: none;
    color: #808080;
}
</style>
<ul id="userToolbar" class="on">
    <li class="first-child"><span id="hiloc">Hi </span>admin</li>
    <li style="list-style:none outside none; margin-left:0">&nbsp;&nbsp;&#8226;&nbsp;&nbsp;<a href="home_loggedout.jst" tabindex="0" id="logout">Logout</a></li>
    <li style="list-style:none outside none; margin-left:0">&nbsp;&nbsp;&#8226;&nbsp;&nbsp;<a href="password_change.jst" tabindex="0" id="chPass">Change Password</a></li>
</ul>
<ul id="status">
    <li id="sta_batt" class="battery first-child"><div class="sprite_cont"><span class="bat-0" ><img src="./cmn/img/icn_battery.png"  alt="Battery icon" title="Battery icon" id="batticonloc" /></span></div><a role="toolbar" href="javascript: void(0);" tabindex="0">0%</a>     <!-- NOTE: When this value changes JS will set the battery icon -->     </li><li id="sta_inet" class="internet"><span class="value on-off sprite_cont"><img src="./cmn/img/icn_on_off.png" alt="Internet Online" /></span><a href="javascript: void(0);" tabindex="0">Internet<div class="tooltip" id="bat_remain">Loading...</div></a></li><li id="sta_wifi" class="wifi"><span class="value on-off sprite_cont"><img src="./cmn/img/icn_on_off.png" alt="WiFi Online" /></span><a href="javascript: void(0);" tabindex="0">Wi-Fi<div class="tooltip" id="bat_remain">Loading...</div></a></li><li id="sta_moca" class="MoCA off"><span class="value on-off sprite_cont"><img src="./cmn/img/icn_on_off.png" alt="MoCA Offline" /></span><a href="javascript: void(0);" tabindex="0">MoCA<div class="tooltip" id="bat_remain">Loading...</div></a></li><li id="sta_fire" class="security last"><span class="value on-off sprite_cont"><img src="./cmn/img/icn_on_off.png" alt="Security On" /></span><a href="javascript: void(0);" tabindex="0"><label id="secuserlocMedium">Medium Security</label><div class="tooltip" id="bat_remain">Loading...</div></a></li>
</ul>

</div><!-- end #sub-header -->

<!-- $Id: nav.dory.jst 3155 2010-01-06 19:36:01Z slemoine $ -->
<!--Nav-->
<div id="nav"><ul><li class="nav-gateway"><a role="menuitem"  title="click to toggle sub menu" class="top-level" href="at_a_glance.jst" id="gatewayloc">Gateway</a><ul><li class="nav-at-a-glance"><a role="menuitem"  href="at_a_glance.jst" id="ataglanceloc">At a Glance</a></li><li class="nav-connection"><a role="menuitem"  title="click to toggle sub menu"  href="javascript:;" id="connloc">Connection</a><ul><li class="nav-connection-status"><a role="menuitem"  href="connection_status.jst" id="statloc">Status</a></li><li class="nav-gateway-network"><a role="menuitem"  href="network_setup.jst">Videotron Network</a></li><li class="nav-local-ip-network"><a role="menuitem"  href="local_ip_configuration.jst" id="locip">Local IP Network</a></li><li class="nav-wifi-config"><a role="menuitem"  href="wireless_network_configuration.jst" id="wifiloc">Wi-Fi</a></li><li class="nav-moca"><a role="menuitem"  href="moca.jst">MoCA</a></li><li class="nav-wan-network"><a role="menuitem"  href="wan_network.jst" id="wannet">WAN Network</a></li></ul></li><li class="nav-firewall"><a role="menuitem"  title="click to toggle sub menu"  href="javascript:;" id="firwlloc">Firewall</a>          <ul>                <li class="nav-firewall-ipv4"><a role="menuitem"  href="firewall_settings_ipv4.jst">IPv4</a></li>               <li class="nav-firewall-ipv6"><a role="menuitem"  href="firewall_settings_ipv6.jst">IPv6</a></li>           </ul>           </li><li class="nav-software"><a role="menuitem"  href="software.jst">Software</a></li><li class="nav-hardware"><a role="menuitem"  title="click to toggle sub menu"  href="javascript:;" id="hrdloc">Hardware</a><ul><li class="nav-system-hardware"><a role="menuitem"  href="hardware.jst" id="hardmess1">System Hardware</a></li><li class="nav-battery"><a role="menuitem"  href="battery.jst" id="battloc">Battery</a></li><li class="nav-lan"><a role="menuitem"  href="lan.jst">LAN</a></li><li class="nav-wifi"><a role="menuitem"  href="wifi.jst">Wireless</a></li></ul></li></ul></li><li class="nav-connected-devices"><a role="menuitem"  title="click to toggle sub menu"  class="top-level" href="connected_devices_computers.jst" id="conndev">Connected Devices</a><ul><li class="nav-cdevices"><a role="menuitem"  href="connected_devices_computers.jst" id="devloc">Devices</a></li></ul></li><li class="nav-parental-control"><a role="menuitem"  title="click to toggle sub menu"  class="top-level" href="managed_sites.jst" id="parloc">Parental Control</a><ul><li class="nav-sites"><a role="menuitem"  href="managed_sites.jst" id="mansitesloc">Managed Sites</a></li><li class="nav-services"><a role="menuitem"  href="managed_services.jst" id="manserloc">Managed Services</a></li><li class="nav-devices"><a role="menuitem"  href="managed_devices.jst" id="mandevloc">Managed Devices</a></li><li class="nav-parental-reports"><a role="menuitem"  href="parental_reports.jst" id="reploc">Reports</a></li></ul></li><li class="nav-advanced"><a role="menuitem"  title="click to toggle sub menu"  class="top-level" href="port_forwarding.jst" id="advloc">Advanced</a><ul><li class="nav-port-forwarding"><a role="menuitem"  href="port_forwarding.jst">Port Forwarding</a></li><li class="nav-port-triggering"><a role="menuitem"  href="port_triggering.jst">Port Triggering</a></li><li class="nav-remote-management"><a role="menuitem"  href="remote_management.jst" id="remloc">Remote Management</a></li><!--li class="nav-qos1"><a role="menuitem"  href="qos1.jst">QoS</a></li--><li class="nav-dmz"><a role="menuitem"  href="dmz.jst">DMZ</a></li><li class="nav-device-discovery"><a role="menuitem"  href="device_discovery.jst" id="devdishead">Device Discovery</a></li></ul></li><li class="nav-troubleshooting"><a role="menuitem"  title="click to toggle sub menu"  class="top-level" href="troubleshooting_logs.jst" id="troubleloc">Troubleshooting</a><ul><li class="nav-logs"><a role="menuitem"  href="troubleshooting_logs.jst" id="logsloc">Logs</a></li><li class="nav-diagnostic-tools"><a role="menuitem"  href="network_diagnostic_tools.jst" id="diagloc">Diagnostic Tools</a></li><li class="nav-wifi-spectrum-analyzer"><a role="menuitem"  href="wifi_spectrum_analyzer.jst" id="wifispecloc">Wi-Fi Spectrum Analyzer</a></li><li class="nav-moca-diagnostics"><a role="menuitem"  href="moca_diagnostics.jst" id="mocdiagloc">MoCA Diagnostics</a></li><li class="nav-restore-reboot"><a role="menuitem"  href="restore_reboot.jst" id="resetloc">Reset/Restore Gateway</a></li><li class="nav-password"><a role="menuitem"  href="password_change.jst" id="chPass">Change Password</a></li></ul></li></ul></div>
<script type="text/javascript">
var o_disableFwForTSI = false;
$(document).ready(function() {
    gateway.page.init("Gateway > Firewall > IPv4", "nav-firewall-ipv4");
    function keyboard_toggle(){
        //var $link = $("#security-level label");
        var $link = $("input[name='firewall_level']");
        var $div = $("#security-level .hide");
        // toggle slide     
        $($link).keypress(function(ev) {
            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
            if (keycode == '13') {
                //e.preventDefault();
                $(this).siblings('.hide').slideToggle();
            }
        });
    }
    keyboard_toggle();  
    /*
     * Toggles Custom Security Checkboxes based on if the Custom Security is selected or not
     */
    $("input[name='firewall_level']").change(function() {
        if($("input[name='firewall_level']:checked").val() == 'custom') {
            $("#custom .target").removeClass("disabled").prop("disabled", false);
        } else {
            $("#custom .target").addClass("disabled").prop("disabled", true);
        }
    }).trigger("change");
    $("#disable_firewall").change(function(){
        if($("#disable_firewall").prop("checked")) {
            var message = $.i18n("You are trying to disable the firewall. It is a security risk. Are you sure you want to continue?");
            jConfirm(
                message
                ,$.i18n('Are you sure?')
                ,function(ret) {
                    if(ret) {
                        $("#block_http").prop("disabled",true).attr('checked', false);
                        $("#block_icmp").prop("disabled",true).attr('checked', false);
                        $("#block_multicast").prop("disabled",true).attr('checked', false);
                        $("#block_peer").prop("disabled",true).attr('checked', false);
                        $("#block_ident").prop("disabled",true).attr('checked', false);
                    }  
                    else
                    {
                        $("#disable_firewall").prop('checked', false);
                    }  
                });
        }
        else {
            $("#block_http").prop("disabled",false);
            $("#block_icmp").prop("disabled",false);
            $("#block_multicast").prop("disabled",false);
            $("#block_peer").prop("disabled",false);
            $("#block_ident").prop("disabled",false);
        }
    });
    if($("#disable_firewall").prop("checked")) {
        $("#block_http").prop("disabled",true).attr('checked', false);
        $("#block_icmp").prop("disabled",true).attr('checked', false);
        $("#block_multicast").prop("disabled",true).attr('checked', false);
        $("#block_peer").prop("disabled",true).attr('checked', false);
        $("#block_ident").prop("disabled",true).attr('checked', false);
    }
    else {
        $("#block_http").prop("disabled",false);
        $("#block_icmp").prop("disabled",false);
        $("#block_multicast").prop("disabled",false);
        $("#block_peer").prop("disabled",false);
        $("#block_ident").prop("disabled",false);
    }
    /*
     * Confirm dialog for restore to factory settings. If confirmed, the hiddin field (restore_factory_settings) is set to true
     */
    $("#restore-default-settings").click(function(e) {
        e.preventDefault();
        var currentSetting = $("input[name=firewall_level]:checked").parent().find("label:first").text();
    $("#block_http").prop("disabled",true).attr('checked', false);
        $("#block_icmp").prop("disabled",true).attr('checked', false);
        $("#block_multicast").prop("disabled",true).attr('checked', false);
        $("#block_peer").prop("disabled",true).attr('checked', false);
        $("#block_ident").prop("disabled",true).attr('checked', false);

        jConfirm(
            $.i18n('The firewall security level is currently set to') +' '+  currentSetting +'. '+ $.i18n('Are you sure you want to change to default settings?')
            ,$.i18n('Reset Default Firewall Settings')
            ,function(ret) {
                if(ret) {
                    $("#firewall_level_maximum").prop("checked",false);
                    $("#firewall_level_minimum").prop("checked",true);
                    var firewallLevel = "Low";
                    var firewallCfg = '{"firewallLevel": "' + firewallLevel + '"}';
                   // alert(firewallCfg);
                    setFirewall(firewallCfg);
                }
            });
    });
    $('#submit_firewall').click(function(){
        var firewallLevel = "None";        
        var level1 = document.getElementById('firewall_level_maximum');
        if (level1.checked) { 
            firewallLevel = "High";
        }
        var level2 = document.getElementById('firewall_level_typical');
        if (level2.checked) { 
            firewallLevel = "Medium";
        }
        var level3 = document.getElementById('firewall_level_minimum');
        if (level3.checked) { 
            firewallLevel = "Low";
        }
        var level4 = document.getElementById('firewall_level_custom');
        if (level4.checked) { 
            firewallLevel = "Custom";
        }
        var blockHttp = "Disabled"; 
        var blockIcmp = "Disabled"; 
        var blockMulticast = "Disabled"; 
        var blockPeer  = "Disabled"; 
        var blockIdent = "Disabled"; 
        var obj1 = document.getElementById('block_http');
        if (obj1.checked) { 
            blockHttp = "Enabled";
        }
        var obj2 = document.getElementById('block_icmp');
        if (obj2.checked) { 
            blockIcmp = "Enabled";
        }
        var obj3 = document.getElementById('block_multicast');
        if (obj3.checked) { 
            blockMulticast = "Enabled";
        }
        var obj4 = document.getElementById('block_peer');
        if (obj4.checked) { 
            blockPeer = "Enabled";
        }
        var obj5 = document.getElementById('block_ident');
        if (obj5.checked) { 
            blockIdent = "Enabled";
        }
        var obj6 = document.getElementById('disable_firewall');
        if (obj6.checked) { 
            if (firewallLevel == "Custom") {
                firewallLevel = "None";
            }
        }
        var firewallCfg = '{"firewallLevel": "' + firewallLevel + '", "block_http": "' + blockHttp + '", "block_icmp": "' + blockIcmp +
                                 '", "block_multicast": "' + blockMulticast + '", "block_peer": "' + blockPeer + '", "block_ident": "' + blockIdent + '"} ';
       // alert(firewallCfg);
        setFirewall(firewallCfg);
    });
    function setFirewall(configuration){
                var token = "c6sxyaaegj";
        jProgress($.i18n('This may take several seconds...'), 60);
        $.ajax({
            type: "POST",
            url: "actionHandler/ajaxSet_firewall_config.jst",
            data: { configInfo: configuration,csrfp_token: token },
            success: function(){            
                jHide();    
                location.reload();
            },
            error: function(){            
                jHide();
                alertLocale('Failure, please try again.');
            }
        });
    }
});
</script>
<div id="content">
    <h1 id="firewall_loc">Gateway > Firewall > IPv4</h1>
    <div id="educational-tip">
        <p class="tip" id="firwlipv4">Manage your firewall settings.</p>
        <p class="hidden" id="firwlipv4tip1">Select a security level for details. If you\'re unfamiliar with firewall settings, keep the default security level, Minimum Security (Low).</p>
        <p class="hidden" id="firwlipv4tip2"><strong>Maxium Security (High):</strong> Blocks all applications, including voice applications (such as Gtalk, Skype) and P2P applications, but allows Internet, email, VPN, DNS, and iTunes services.</p>
        <p class="hidden" id="firwlipv4tip3"><strong>Typical Security (Medium):</strong> Blocks P2P applications and pings to the Gateway, but allows all other traffic.</p>
        <p class="hidden" id="firwlipv4tip4"><strong>Minimum Security (Low):</strong> No application or traffic is blocked. (Default setting)</p>
        <p class="hidden" id="firwlipv4tip5"><strong>Custom security:</strong> Block specific services.</p>
    </div>
    <div class="module">
        <form id="pageForm">
        <input type="hidden" name="restore_factory_settings" id="restore_factory_settings" value="false" />
        <h2 id="firseclev">Firewall Security Level</h2>
        
        <ul class="combo-group" id="security-level">
            <li id="max">
                <input type="radio" name="firewall_level" value="high" id="firewall_level_maximum" />
                <label for="firewall_level_maximum" class="label" id="maxsechigh">Maximum Security (High)
                </label>
                
                <div class="hide">
                    <p id="firwlsec1"><strong>LAN-to-WAN :</strong> Allow as per below.</p>
                    <dl>
                    <dd id="firwldd1">HTTP and HTTPS (TCP port 80, 443)</dd>
                    <dd id="firwldd2">DNS (TCP/UDP port 53)</dd>
                    <dd id="firwldd3">NTP (TCP port 119, 123)</dd>
                    <dd id="firwldd4">email (TCP port 25, 110, 143, 465, 587, 993, 995)</dd>
                    <dd id="firwldd5">VPN (GRE, UDP 500, 4500, 62515, TCP 1723)</dd>
                    <dd id="firwldd6">iTunes (TCP port 3689)</dd>
                    </dl>
                    <p id="firmess1"><strong>WAN-to-LAN :</strong> Block all unrelated traffic and enable IDS.</p>
                </div>
            </li>
            <li id="medium">
                <input type="radio" name="firewall_level" value="medium" id="firewall_level_typical" checked />
                <label for="firewall_level_typical" class="label" id="firtypesecmed">Typical Security (Medium)</label>
                <div class="hide">
                    <p id="firmess2"><strong>LAN-to-WAN :</strong> Allow all.</p>
                    <p id="firmess3"><strong>WAN-to-LAN :</strong> Block as per below and enable IDS.</p>
                    <dl>
                    <dd  id="firmess4">IDENT (port 113)</dd>
                    <dd id="firmess5">ICMP request</dd>
                    <dd>
                    <dl>
                    <dt id="firmess6">Peer-to-peer apps:</dt>
                    <dd id="firmess7">kazaa - (TCP/UDP port 1214)</dd>
                    <dd id="firmess8">bittorrent - (TCP port 6881-6999)</dd>
                    <dd id="firmess9">gnutella- (TCP/UDP port 6346)</dd>
                    <dd id="firmess10">vuze - (TCP port 49152-65534)</dd>
                    </dl>
                    </dd>
                    </dl>
                </div>
            </li>
            <li id="low">
                <input type="radio" name="firewall_level" value="low" id="firewall_level_minimum"   />
                <label for="firewall_level_minimum" class="label" id="minsec">Minimum Security (Low)</label>
                <div class="hide">
                    <p id="firmess2"><strong>LAN-to-WAN :</strong> Allow all.</p>
                    <p id="firmess3"><strong>WAN-to-LAN :</strong> Block as per below and enable IDS</p>
                    <dl>
                    <dd id="firmess4">IDENT (port 113)</dd>
                    </dl>
                </div>
            </li>
            <li id="custom">
                <input class="trigger" type="radio" name="firewall_level" value="custom" id="firewall_level_custom" 
                 />
                <label for="firewall_level_custom" class="label" id="cussec">Custom Security</label>
                <div class="hide">
                <p id="firmess2"><strong>LAN-to-WAN :</strong> Allow all.</p>
                <p id="firmess11"><strong>WAN-to-LAN :</strong> IDS Enabled and block as per selections below.</p>
                <p class="target disabled">
                <input class="target disabled"  type="checkbox" id="block_http" name="block_http" 
                 /> 
                <label for="block_http" id="firmess12">Block http (TCP port 80, 443)</label><br />
                <input class="target disabled"  type="checkbox" id="block_icmp" name="block_icmp"
                 />
                <label for="block_icmp" id="firmess13">Block ICMP</label><br />
                <input class="target disabled"  type="checkbox" id="block_multicast" name="block_multicast"
                 /> 
                <label for="block_multicast" id="firmess14">Block Multicast</label><br />
                <input class="target disabled"  type="checkbox" id="block_peer" name="block_peer" 
                  /> 
                <label for="block_peer"  id="firmess15">Block Peer-to-peer applications</label><br />
                <input class="target disabled" type="checkbox" id="block_ident" name="block_ident" 
                  /> 
                <label for="block_ident"  id="firmess16">Block IDENT (port 113)</label><br />
                <input class="target disabled" type="checkbox" id="disable_firewall" name="disable_firewall" 
                   />
                <label for="disable_firewall" id="firmess17">Disable entire firewall</label>
                </p>
                </div>
            </li>
        </ul>
        <div class="form-btn"> 
            <input id="submit_firewall"  type="button" value="Save Settings" class="btn" />
            <input id="restore-default-settings" type="button" value="Restore Default Settings" class="btn alt" />
        </div>
        </form>
    </div> <!-- end .module -->
</div><!-- end #content -->

<!-- $Id: footer.jst 2976 2009-09-02 21:42:51Z cporto $ -->
        </div> <!-- end #main-content-->
        <!--Footer-->

        <div id="footer">
            <ul id="footer-links">
                <li class="first-child" style="width:405px;"><a href="https://www.videotron.com" target="_blank">Videotron.com</a></li>
            </ul>
        </div> <!-- end #footer -->
    </div> <!-- end #container -->
<script type="text/javascript">
$(document).ready(function() {
    // focus current page link, must after page.init()
    //$('#nav [href="'+location.href.replace(/^.*\//g, '')+'"]').focus();       // need a "skip nav" function
    $("#skip-link").click(function () {
        $('#content').attr('tabIndex', -1).focus();  //this is to fix skip-link doesn't work on webkit-based Chrome
    });
    // change radio-btn status and do ajax when press "enter"
    //$(".radio-btns a").keydown(function(event){
    $(".radio-btns a").keypress(function(event){
        var keycode = (event.keyCode ? event.keyCode : event.which);
        if(13 == keycode){
            if (!$(this).parent(".radio-btns").find("li").hasClass("selected")){
                return;     // do nothing if has disabled class, don't detect disabled attr for radio-btn
            }
            // console.log($(this).find(":radio").hasClass("disabled"));
            $(this).find(":radio").trigger('click');
            $(this).find(":radio").trigger('change');
            $(this).parent(".radio-btns").radioToButton();
        }
    });
    // press Esc to skip menu and goto first control of content
    // Esc:keypress:which is zero in FF, Esc:keypress is not work in Chrome
    $("#nav").keydown(function(event){
        var keycode = (event.keyCode ? event.keyCode : event.which);
        if(27 == keycode){
            $("#content textarea:eq(0)").focus();
            $("#content input:eq(0)").focus();
            $("#content a:eq(0)").focus();          // high priority element to focus           
        }
        // alert(event.keyCode+"---"+event.which+"---"+event.charCode);     
    });
    /* changes for high contrast mode */
    $.highContrastDetect({useExtraCss: true, debugInNormalMode: false});
    if ($.__isHighContrast) {
        /* change plus/minus tree indicator of nav menu */
        $("#nav a.top-level").prepend('<span class="hi_nav_top_indi">[+]</span>');
        $("#nav a.folder").prepend('<span class="hi_nav_folder_indi">[+]</span>');
        $("#nav a.top-level-active span.hi_nav_top_indi").text("[-]");
        $("#nav a.folder").click(function() {
            /* this should be called after nav state changed */
            var $link = $(this);
            if ($link.hasClass("folder-open")) {
                $link.children("span.hi_nav_folder_indi").text("[-]");
            }
            else {
                $link.children("span.hi_nav_folder_indi").text("[+]");
            }
        });
    }
    /*
    *   these 3 sections for radio-btn accessibility, as a workaround, maybe should put at the front of .ready().
    */
    // add "role" and "title" for ARIA, attr may need to be embedded into html
    $(".radio-btns a").each(function(){
        $(this).attr("role", "radio").attr("title", $(this).closest("ul").prev().text() + $(this).find("label").text());
    });
    // monitor "aria-checked" status for JAWS, NOTE: better depends on input element
    $(".radio-btns").change(function(){
        $(this).find("a").each(function(){
            $(this).attr("aria-checked", $(this).find("input").attr("checked") ? "true" : "false");
        });
    });
    //give the initial status, do not trigger change above
    $(".radio-btns").find("a").each(function(){
        $(this).attr("aria-checked", $(this).find("input").attr("checked") ? "true" : "false");
    });

});
</script>   
</body>
</html>


#>

