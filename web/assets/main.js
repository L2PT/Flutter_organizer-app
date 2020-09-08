const homeRoute = '/';
const monthlyCalendarRoute = 'view/monthly_calendar';
const dailyCalendarRoute = 'view/daily_calendar';
const operatorListRoute = 'view/op_list';
const registerRoute = 'view/register';
const detailsEventViewRoute = 'view/details_event';
const createEventViewRoute = 'view/form_event_creator';
const waitingEventListRoute = 'view/waiting_event_list';
const waitingNotificationRoute = 'view/persistent_notification';
const historyEventListRoute = 'view/history_event_list';
const profileRoute = 'view/profile';
const resetCodeRoute = 'view/reset_code_page';
const logInRoute = 'view/log_in';
const logOut = 'log_out';


var calendar;
var db;
var storage;
var categories;
var dart;
var idUtente;

$(function() {

    var firebaseConfig = {
              apiKey: "AIzaSyD3A8jbx8IRtXvnmoGSwJy2VyRCvo0yjGk",
              authDomain: "com-l2pt-venturiautospurghi.firebaseapp.com",
              databaseURL: "https://com-l2pt-venturiautospurghi.firebaseio.com",
              projectId: "com-l2pt-venturiautospurghi",
              storageBucket: "com-l2pt-venturiautospurghi.appspot.com",
              messagingSenderId: "964614131015",
              appId: "1:964614131015:web:8a10af66f5b15bad589062"
    };
    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
    db = firebase.firestore();
    storage = firebase.storage();

    //Initialize Categories
    var docRef = db.collection("Costanti").doc("Categorie");
    docRef.get().then(function(doc) {
        if (doc.exists) {
            categories = doc.data();
            categories['default'] = '#fda90a';
        } else {
            console.log("No categories!");
        }
    }).catch(function(error) {
        console.log("Error getting categories:", error);
    });

    //Initialize the calendar controls
    $(document).on('click',".fc-resource-header-postfix",function(){
        showDialogByContext_dart(operatorListRoute,null);
    });
    $(document).on('click',".fc-resource-postfix",function(){
        var id = $(this).closest('tr').data("resource-id")
        removeResource(id)
    });

});

//Initialize the calendar (this will be called after login) <-- Dart
function initCalendar(){
//   $('#calendar').fullCalendar( 'addResource',        { id: 'g', title: 'Matteo', eventColor: 'orange' },);
//   $('#calendar').fullCalendar('today');
     $('#calendar').fullCalendar({
        timezone:'local',
        local: 'it',
        schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
        now: formatDate(new Date()),
        editable: false, // enable draggable events
        droppable: false, // allows things to be dropped onto the calendar
        aspectRatio: 2.4,
        scrollTime: '00:00', // undo default 6am scrollTime
        header: {
                left: '',
                center: '',
                right: ''
              },
        defaultView: 'timelineDay',
        resourceLabelText: 'Tutti gli operatori',
        eventDataTransform: mapEventObj,
        resources: readResources,
        refetchResourcesOnNavigate: true,
        events: readEvents,
        drop: function(date, jsEvent, ui, resourceId) {
            console.log('drop', date.format(), resourceId);

            // is the "remove after drop" checkbox checked?
            if ($('#drop-remove').is(':checked')) {
              // if so, remove the element from the "Draggable Events" list
              $(this).remove();
            }
        },
        eventReceive: function(event) { // called when a proper external event is dropped
            console.log('eventReceive', event);
        },
        eventDrop: function(event) { // called when an event (already on the calendar) is moved
            console.log('eventDrop', event);
        },
        eventClick: function(calEvent, jsEvent, view) {//tell to dart to open the modal
            showDialogByContext_dart(detailsEventViewRoute, JSON.stringify(calEvent, censorMap(calEvent)))
        }
        });
        calendar = $('#calendar').fullCalendar('getCalendar');
        db.collection("Eventi").onSnapshot(function(querySnapshot) {
            calendar.refetchEvents();
        });
}

function readResources(callback){
    var docRef = db.collection("Utenti").doc(idUtente);
    docRef.get().then(function(doc) {
        if (doc.exists) {
            var arr = doc.data().OperatoriWeb;
            var res = [];
            for( var i = 0; i < arr.length; i++){
                if(typeof(arr[i].title) == 'undefined'){
                    arr[i].title = arr[i]["Cognome"]+" "+arr[i]["Nome"];
                }
                res.push(arr[i]);
            }
            callback(res);
        } else {
            console.log("No web operator!");
        }
    }).catch(function(error) {
        console.log("Error getting user", error);
    });
}
function readEvents(start, end, timezone, callback){
   //var date = calendar.getDate().format();
   var docRef = db.collection("Eventi");
   var evs = [];
   docRef.get().then(function(querySnapshot) {
       querySnapshot.forEach(function(doc) {
           var e = doc.data();
           e.id= doc.id;
           evs.push(e)
       });
       callback(evs);
   }).catch(function(error) {
       console.log("Error getting Events:", error);
       callback(evs);
   });
}
function mapEventObj(eventData){
    if(eventData!=null){
        var e = eventData;
        e.resourceId = e.IdOperatore;//TODO
        e.resourceIds = e.IdOperatori;
        e.title = e.Titolo;
        e.url = e.Categoria;
        e.color = getColor(e.Categoria);
        e.start = new Date(e.DataInizio.seconds*1000).toISOString()//TODO
        e.end = new Date(e.DataFine.seconds*1000).toISOString()
        return e;
    }
}
function removeResource(res){
    calendar.removeResource(res).then(function(value){
        //TODO removeResource_dart(res);
//          dynamic j = null;
//            for(dynamic o in account.webops){
//              if(Account.fromMap(null, o).id == res) j=o;
//            }
//            if(j!=null) account.webops.remove(j);
//            OperatorsRepository().updateOperator(account.id, "OperatoriWeb", account.webops);
    });
}

//<-- Dart
function addResources(res){
    res.forEach(function(i){
        i.title = i["surname"]+" "+i["name"];
        calendar.addResource(i);
    })
}
//<-- Dart
async function storageOpenUrl(path){
    var downloadUrl = await storage.ref().child(path).getDownloadURL();
    window.open(downloadUrl);
}
//<-- Dart
async function storageGetFiles(path){
    var a = (await storage.ref().child(path).listAll());
    return a;
}
//<-- Dart
function storagePutFile(path, file){
    storage.ref().child(path).put(file);
}
//<-- Dart
function storageDelFile(path){
    storage.ref().child(path).delete();
}


/*-------------------------------------------------------------------*/
                        /*--UTILITIES--*/
function getColor(arg){
    return (arg != null && typeof(arg) != 'undefined' && categories[arg] != null)?categories[arg]:categories['default'];
}

function formatDate(date) {
      var day = date.getDate();
      var monthIndex = date.getMonth()+1;
      var year = date.getFullYear();

      return year + '-' + ((monthIndex/10<1)?0+''+monthIndex:monthIndex) + '-' + ((day/10<1)?0+''+day:day);
}

function censorMap(censor) {
  var i = 0;

  return function(key, value) {
    if(i !== 0 && typeof(censor) === 'object' && typeof(value) == 'object' && censor == value)
      return '[Circular]';

    if(key == "source") // seems to be a harded maximum of 30 serialized objects?
      return '[Censor]';

    ++i; // so we know we aren't using the original object anymore

    return value;
  }
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}
function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  var expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

/*          DART            */
//accessors
function WriteCookieJarJs(name,val) { setCookie(name,val,val==""?-10:1);}
function ReadCookieJarJs(name) { return getCookie(name);}

function storageOpenUrlJs(path){ storageOpenUrl(path); };
async function storageGetFilesJs(path){ return await storageGetFiles(path); };
function storagePutFileJs(path, file){ storagePutFile(path, file); };
function storageDelFileJs(path){ storageDelFileJs(path); };

function showAlertJs(value) { alert(value);}
function consolLogJs(value) { console.log(value);}






