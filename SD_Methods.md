# SD Methods

script 00.R cd
/Users/urbanorc/Dropbox/Projects/DS\_Synthetic\_Derivative/DS/Proc

## Case Selection from the Synthetic Derivative

Down syndrome cases

The first step in using the SD is to define a set of target cases. The
SD set named 'DS2' has 2,420 cases with a ICD9 code of 758.0. All
subsequent retrievals from SD use the cases in the 'DS2' dataset.

The SD 'Set Tools tab' allows exporting of ICD code, CPT codes, labs and
vital signs.

Each export dataset is limited to 10,000 records.

ICD, CPT and Lab codes require the user to manually select specific
values. Vital signs have checkboxes and multiple measures may be
selected at once.

### Labs records have Date, Time, Short Name, Long Name, Value, Abnormal, Age at event

### CPT Code records have Date, Code, Description, age at event

### ICD Code records have Date, Code, Description, age at event

### Vital Signs -- Date, Time, Value, Age at event for BP; BMI; Height; Weight; Resp Rate

The SD 'Set tool tab' does not allow exporting Medications or Documents.
To export medications and documents, Cole Beck created four javascript
functions for the Firefox browser to extract information from these
sources to the system clipboard. The javascripts functions *GetMeds*,
*Copy! And GetDocs* and *CopyDocs!* were used retrieve information from
a displayed case and save in the system clipboard. A support Ruby
program was then used to save the data in the system clipboard to a
file. The file name includes the unique studyid from the case retrieved.
Thus, there is one file per case per data type.

### Medications summary -- Drug Name, Mentions, First Mention Date, Last Mention

    Requires GetMeds and Copy! Functions to retrieve

### Medications Details -- Date, Time,Drug name, form, strength, amount, route,

      Requires GetMeds and CopyDetails! Functions to retrieve

### Documents -- High Value; Other; Problem Lists -- requires *GetDocs and CopyDocs!* functions.

**Control cases**

Our goal was to create a Control group matched on year of birth with the
cases in the DS group. Since birth year is not a variable available for
selection of cases and each export may have no more than 10,000 records,
retrieval of information for the Control group could not be accomplished
using a single dataset like the DS2 dataset for DS cases. Five datasets
were defined based on gender and age. The final age ranges include was
accomplished through trial and error. Various potential age values were
tried. The final export datasets had the number of records closest to
but not more than 10,000.

Table 1. Datasets exported from the Synthetic Derivative.

+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
|                       | DS                    | Age                   | V30                   | Gender                | Number of Records     |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| V30MF14\_55           | No                    | 14-55                 | Yes                   | Male & Female         | 6,564                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| V30MnDS7-13           | No                    | 7-13                  | Yes                   | Male                  | 8,914                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| V30FnDS7-13           | No                    | 7-13                  | Yes                   | Female                | 8,426                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| V30FnDS0-6            | No                    | 0-6                   | YES                   | Female                | 7,612                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| V30MnDS0-6            | No                    | 0-6                   | Yes                   | Male                  | 8,450                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+
| DS2                   | Yes                   | 0-55                  | All                   | Both                  | 2,420                 |
+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+-----------------------+

Processing

10ds1.R

15ds2.R 15ds\_rx.R 40ds\_cpt.R 50ds\_icd\_1.R \#read in icd codes and
format save icd.RData 60getV30.R

60Hamza.R \#create dataset for hamza

demo\_v30.RData has demo data on 163 selected cases

60join (Richard Urbano's conflicted copy 2013-12-16).R 60join.R 65v30.R
70join.R 80bwgt.R

AgeFirstVisit.png AgeToday.pdf DOB Year.pdf meds.R rx.tab template.pdf
episodes\_l.R --'/Users/urbanorc/Dropbox/Projects/R/episodes\_l.R'

=-=-=-=-=-=-=-=-=-=-

15ds1.R -- added ti 10ds1.R don't run 20.R grab data directly from mysql
DON'T RUN 30.ds\_cpt.R 40.vitals\_wide.R 60Episodes.R 0Hamza\_long.R
