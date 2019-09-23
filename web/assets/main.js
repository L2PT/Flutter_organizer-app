var calendar;
var db;
var categories;
var loggedId = "PCsJ86Gtiww4tmjbttu4";
$(function() { // document ready
// Your web app's Firebase configuration
    var firebaseConfig = {
        apiKey: "AIzaSyD5sZzeqqH_wje72BWe3zoOR136YEh186k",
        authDomain: "com-l2pt-venturiautospurghi.firebaseapp.com",
        databaseURL: "https://com-l2pt-venturiautospurghi.firebaseio.com",
        projectId: "com-l2pt-venturiautospurghi",
        storageBucket: "com-l2pt-venturiautospurghi.appspot.com",
        messagingSenderId: "964614131015",
        appId: "1:964614131015:web:8a10af66f5b15bad589062"
    };
    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
    db=firebase.firestore();
    initCategories();

    /* initialize the calendar
    -----------------------------------------------------------------*/
    $('#calendar').fullCalendar({
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
    now: '2019-09-22',//formatDate(new Date()),
    editable: true, // enable draggable events
    droppable: true, // this allows things to be dropped onto the calendar
    aspectRatio: 2,
    scrollTime: '00:00', // undo default 6am scrollTime
    header: {
            left: '',
            center: 'prev,next title',
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
    }
    });
    calendar = $('#calendar').fullCalendar('getCalendar');
//              $('#calendar').fullCalendar( 'addResource',        { id: 'g', title: 'Matto', eventColor: 'orange' },);
//              $('#calendar').fullCalendar('today');

    $(document).on('click',".fc-resource-postfix",function(){
        $(this).closest('tr').data("resource-id");
    });


  });


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
    var docRef = db.collection("Utenti").doc(loggedId);
    var docRef = db.collection("Utenti").where("Responsabile", "==", false);//TODO FIX THIS QUERY
    var res = [];
    docRef.get().then(function(querySnapshot) {
        querySnapshot.forEach(function(doc) {
            var d = doc.data();
            d.id= doc.id;
            d.title= d.Cognome + " " + d.Nome;
            //calendar.addResource(d);
            res.push(d);
        });
        callback(res);
    }).catch(function(error) {
        console.log("Error getting Resources:", error);
    });
}
function readEvents(start, end, timezone, callback){
    //var date = calendar.getDate().format();
    var docRef = db.collection("Eventi").where("Data inizio",">=",firebase.firestore.Timestamp.fromDate(new Date()))  ; //TODO ADD QUERY FOR RESOURCES ID
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

}
function mapEventObj(eventData){
    if(eventData!=null){
        var e = eventData;
        e.resourceId = "6wsK67Ru0qZmUBoY5cSm";
        e.resourceIds = e.subop;
        e.title = e.Descrizione;
        e.url = e.Tipo;
        e.color = getColor(e.Tipo);
        e.start = '2019-09-22T03:00:00';
        e.end = '2019-09-22T09:00:00';
        return e;
    }
}

/*-------------------------------------------------------------------*/
                        /*--UTILITIES--*/
function getColor(arg){
    return (arg != null && categories[arg] != null)?categories[arg]:categories['default'];
}

function formatDate(date) {
      var day = date.getDate();
      var monthIndex = date.getMonth();
      var year = date.getFullYear();

      return year + '-' + monthIndex + '-' + day;
}
