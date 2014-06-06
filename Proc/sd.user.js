// ==UserScript==
// @name          SynDer Meds
// @namespace     https://biovu.vanderbilt.edu/SD/
// @description   Scrape medications from synthetic derivative
// @version       1.0
// @include       https://biovu.vanderbilt.edu/*
// @grant         GM_setClipboard
// @grant         GM_getValue
// @grant         GM_setValue
// @grant         GM_deleteValue
// ==/UserScript==

var ans = GM_getValue("ans", "");
var ans1 = GM_getValue("ans1", "");
var ans2 = GM_getValue("ans2", "");

function onTab(tab) {
  ret = 0;
  a = document.getElementsByClassName('v-tabsheet-tabs-minimal')[0].children[0].children[0].children;
  for(i=0; i < a.length; i++) {
    if(a[i].classList.contains('v-tabsheet-tabitemcell-selected')) {
      if(a[i].textContent.startsWith(tab)) ret=1;
    }
  }
 return ret;
}

function getMeds() {
  if(onTab("Medications")) {
    c = document.getElementsByClassName('v-button-link');
    id = c[c.length-1].children[0].children[0].textContent;
    b = document.getElementsByClassName('v-table-table')[0].children[0].children;
    for(i=0; i < b.length; i++) {
      name = b[i].children[0].textContent;
      count = b[i].children[1].textContent;
      first = b[i].children[2].textContent;
      last = b[i].children[3].textContent;
      ans += id + "\t" + name + "\t" + count + "\t" + first + "\t" + last + "\n";
    }
    d = document.getElementsByClassName('v-table-table')[1].children[0].children;
    for(i=0; i < d.length; i++) {
      det = [id];
      for(j=0; j < d[i].children.length; j++) {
        det.push(d[i].children[j].textContent);
      }
      ans1 += det.join("\t") + "\n";
    }
    GM_setValue("ans", ans);
    GM_setValue("ans1", ans1);
  } else {
    alert('not on medications tab');
  }
}

function getDocs() {
  if(onTab("Documents")) {
    c = document.getElementsByClassName('v-button-link');
    id = c[c.length-1].children[0].children[0].textContent;
    b = document.getElementsByClassName('v-customlayout')[1].children[0].children[0].children;
    ans2 += "##################################################\n";
    ans2 += id + "\n";
    ans2 += "##################################################\n";
    // even rows are column headers with col_length 3
    // odd rows are text with col_length 1
    for(i=0; i < b.length; i++) {
      if(b[i].children.length == 3) {
        c1 = b[i].children[0].textContent;
        c2 = b[i].children[1].textContent;
        c3 = b[i].children[2].textContent;
        ans2 += "#########################\n";
        ans2 += c1 + "\t" + c2 + "\t" + c3 + "\n";
        ans2 += "#########################\n";
      } else if(b[i].children.length == 1) {
        ans2 += b[i].children[0].textContent + "\n";
      }
    }
    GM_setValue("ans2", ans2);
  } else {
    alert('not on documents tab');
  }
}
// function getMeds() {
//   b = document.getElementById('huge').children[0].children;
//   for(i=0; i < b.length; i++) {
//     name = b[i].children[0].textContent;
//     count = b[i].children[1].textContent;
//     ans += name + "\t" + count + "\n";
//   }
//   GM_setValue("ans", ans);
// }

function copy2clip() {
  r = GM_getValue("ans", "");
  if(r == '') {
    alert('nothing to copy');
  } else {
    GM_deleteValue("ans");
    ans = GM_getValue("ans", "");
    GM_setClipboard(r);
    alert('copied to clipboard');
  }
}

function copy2clip2() {
  r = GM_getValue("ans1", "");
  if(r == '') {
    alert('nothing to copy');
  } else {
    GM_deleteValue("ans1");
    ans1 = GM_getValue("ans1", "");
    GM_setClipboard(r);
    alert('copied to clipboard');
  }
}

function copy2clip3() {
  r = GM_getValue("ans2", "");
  if(r == '') {
    alert('nothing to copy');
  } else {
    GM_deleteValue("ans2");
    ans2 = GM_getValue("ans2", "");
    GM_setClipboard(r);
    alert('copied to clipboard');
  }
}

window.addEventListener("load", function(e) {
  addButtons();
}, false);

function addButtons() {
  var elem = document.createElement('div');
  var in1 = document.createElement('input');
  in1.setAttribute('type', 'button');
  in1.setAttribute('name', 'meds');
  in1.setAttribute('id', 'meds');
  in1.setAttribute('value', 'GetMeds');
  in1.addEventListener('click', getMeds, true);
  elem.appendChild(in1);
  var in2 = document.createElement('input');
  in2.setAttribute('type', 'button');
  in2.setAttribute('name', 'copy');
  in2.setAttribute('id', 'copy');
  in2.setAttribute('value', 'Copy!');
  in2.addEventListener('click', copy2clip, true);
  elem.appendChild(in2);
  var in3 = document.createElement('input');
  in3.setAttribute('type', 'button');
  in3.setAttribute('name', 'copy2');
  in3.setAttribute('id', 'copy2');
  in3.setAttribute('value', 'Copy Details!');
  in3.addEventListener('click', copy2clip2, true);
  elem.appendChild(in3);
  // document info
  var in4 = document.createElement('input');
  in4.setAttribute('type', 'button');
  in4.setAttribute('name', 'docs');
  in4.setAttribute('id', 'docs');
  in4.setAttribute('value', 'GetDocs');
  in4.addEventListener('click', getDocs, true);
  elem.appendChild(in4);
  var in5 = document.createElement('input');
  in5.setAttribute('type', 'button');
  in5.setAttribute('name', 'copy3');
  in5.setAttribute('id', 'copy3');
  in5.setAttribute('value', 'Copy Docs!');
  in5.addEventListener('click', copy2clip3, true);
  elem.appendChild(in5);
  var first = document.body.children[0];
  first.parentNode.insertBefore(elem, first);
}
