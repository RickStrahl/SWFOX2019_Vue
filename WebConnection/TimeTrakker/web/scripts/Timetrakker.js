
function getActiveProjectsForCustomer(custId) {
    if (typeof custId !== "number")
        custId = document.getElementById("CustomerPk").value;

    ajaxJson("Callbacks.ttk?method=GetActiveProjectsForCustomer",
            custId * 1,        
            function (projects) {
                
                // add first item
                projects.unshift({ projname: "-- Select a Project", pk: 0 });


                $("#ProjectPk")
                    .listSetData(projects,
                    {
                        dataTextField: "projname",
                        dataValueField: "pk"
                    });

                if (projects.length < 2)
                    return;
                                
                $("#ProjectPk").val(projects[1].pk.toString())
            },onPageError);
}

/*
Pass:
{
    "pk": 2393,
    "timein": "2015-10-01T12:40:00",
    "timeout": "2015-10-01T12:55:00",
    "billrate": 150.0
}
*/
function updateEntryTotals() {
    var parms = {
        timein: $("#TimeIn_field").val(),
        timeout: $("#TimeOut_field").val(),
        billrate: $("#Rate").val() * 1,
        pk: $("#Pk").val() * 1
    };

    
    parms.timein = moment(parms.timein);
    parms.timeout = moment(parms.timeout);

    ajaxJson("callbacks.ttk?method=UpdateEntryTotals",
            parms,        
            function (totals) {
                $("#TotalHours").text(totals.totalhours);
                $("#ItemTotal").text(totals.itemtotal);

                // adjust this in case we updated it
                $("#TimeOut").val(totals.timeout);

                if (totals.message) {
                    toastr.error(totals.message);
                }
            },onPageError);
}

function onPageError(err) {
    if (!toastr) {
        showStatus(err.message || err.Message, 6000, true);
        return;
    }
    
    toastr.warning(err.message || err.Message,"An error occurred.");
};
