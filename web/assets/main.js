var calendar;
var db;
var categories;
var dart;
$(function() { // document ready
// Your web app's Firebase configuration
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

    initCategories();

    /* initialize the calendar
    -----------------------------------------------------------------*/
    //this will be done after login

//              $('#calendar').fullCalendar( 'addResource',        { id: 'g', title: 'Matto', eventColor: 'orange' },);
//              $('#calendar').fullCalendar('today');

    $(document).on('click',".fc-resource-header-postfix",function(){
        dart.showDialogWindow("add_operator",null);
    });

    $(document).on('click',".fc-resource-postfix",function(){
        var id = $(this).closest('tr').data("resource-id")
        removeResource(id)
    });


  });

function initCalendar(){
     $('#calendar').fullCalendar({
        timezone:'local',
        local: 'it',
        schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
        now: formatDate(new Date()),
        editable: false, // enable draggable events
        droppable: false, // this allows things to be dropped onto the calendar
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
            dartCallback("stampa da js");
        },
        eventClick: function(calEvent, jsEvent, view) {//tell to dart to open the modal
            dart.showDialogWindow("event",calEvent)
        }
        });
        calendar = $('#calendar').fullCalendar('getCalendar');
        db.collection("Eventi").onSnapshot(function(querySnapshot) {
            calendar.refetchEvents();
        });
}

function initCategories(){
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
}

function readResources(callback){
    var docRef = db.collection("Utenti").doc(dart.account.id);
    docRef.get().then(function(doc) {
        if (doc.exists) {
            var arr = doc.data().OperatoriWeb
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

function removeResource(res){
    calendar.removeResource(res).then(function(value){
        dart.removeResource(res);
    });
}

function addResource(res){
    res.forEach(function(i){
        i.title = i["surname"]+" "+i["name"];
        calendar.addResource(i);
    })
}

function deleteEvent(id, event){
    //here cause transactions in dart web give error
    db.runTransaction(async function(transaction) {
        var docRef = db.collection("Eventi").doc(id);
        var a = await transaction.set(db.collection("EventiEliminati").doc(id), JSON.parse(event));
        return await transaction.delete(docRef);
    }).catch(function(error) {
        console.log("Error in trasaction: deleteEvent - ", error);
    });
}

  async function storageGetUrlJs(path){
    storage = firebase.storage();
    var downloadUrl = await storage.ref().child(path).getDownloadURL();
    window.open(downloadUrl);
  }

  function storagePutFileJs(path, file){
    storage = firebase.storage();
    storage.ref().child(path).put(file);
  }

  function storageDelFileJs(path){
    storage = firebase.storage();
    storage.ref().child(path).delete();
  }

function mapEventObj(eventData){
    if(eventData!=null){
        var e = eventData;
        e.resourceId = e.IdOperatore;
        e.resourceIds = e.IdOperatori;
        e.title = e.Titolo;
        e.url = e.Categoria;
        e.color = getColor(e.Categoria);
        e.start = new Date(e.DataInizio.seconds*1000).toISOString()
        e.end = new Date(e.DataFine.seconds*1000).toISOString()
        return e;
    }
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
function initJs2Dart(callback){
    dart=callback;
}

function cookieJar(name, val){
    if(val!=null){
        if(val == "") setCookie(name, val, 1);
        else setCookie(name, val, -10);
    }
    else return getCookie(name);
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

function showAlert(msg){
    alert(msg);
}
