const url = 'http://127.0.0.1:5000';
const passTestDiv = document.getElementById("passTestDiv");
const signInForm = document.getElementById("signIn");
const loggedInSection = document.getElementById("loggedInSection");
const employeeForm = document.getElementById("employeeForm");
const clientForm = document.getElementById("clientForm");
const productForm = document.getElementById("productForm");
const productWiseClientsSearch = document.getElementById("productWiseClientSearch");
const employeeSearch = document.getElementById("employeeSearch");
const clientSearch = document.getElementById("clientSearch");
const productSearch = document.getElementById("productSearch");
const tableSelect = document.getElementById("searchTable");
const searchType = document.getElementById("searchValues");
const signInMessage = document.getElementById("signInMessage");
document.getElementById('year').textContent = new Date().getFullYear();
const searchResultsDiv = document.getElementById("resultDiv");

let loggedIn = false;
let tableName = null;
let fieldName = null;
let fieldValue = null;
let specificValue = null;
let productValue = null;
let doc_path = null;

if(!loggedIn){
  loggedInSection.style.display="none";
}

function displayForm(formName) {
  if (formName.value === "employee") {
    employeeForm.style.display = "block";
    clientForm.style.display = "none";
    productForm.style.display = "none";
  } else if (formName.value === "client") {
    productSelection("clientProduct");
    employeeForm.style.display = "none";
    clientForm.style.display = "block";
    productForm.style.display = "none";
  } else if (formName.value === "product") {
    employeeForm.style.display = "none";
    clientForm.style.display = "none";
    productForm.style.display = "block";
  }
}

function productSelection(id) {
  fetch(url + "/product_list", {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  })
    .then((response) => response.json())
    .then((data) => {
      productSelect = document.getElementById(id);
      if (productSelect.length != 1) {
        return;
      }
      for (let i = 0; i < data.length; i++) {
        productSelect.add(new Option(data[i][1], data[i][1]));
      }
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

function searchTable(table) {
  tableName = table.value;
  if (tableName === "productWiseClients") {
    searchType.style.display = "none";
    employeeSearch.style.display = "none";
    clientSearch.style.display = "none";
    productSearch.style.display = "none";
    productWiseClientsSearch.style.display = "block";
    productSelection("productWiseClientSearch");
  } else {
    productWiseClientsSearch.style.display = "none";
    employeeSearch.style.display = "none";
    clientSearch.style.display = "none";
    productSearch.style.display = "none";
    searchType.value = "";
    searchType.style.display = "block";
  }
  if (searchResultsDiv.hasChildNodes()) {
    searchResultsDiv.innerHTML = "";
  }
}

function searchValues(field) {
  fieldName = field.value;
  if (tableName && field.value !== "all") {
    if (tableName === "employees") {
      employeeSearch.style.display = "block";
    } else if (tableName === "clients") {
      clientSearch.style.display = "block";
    } else if (tableName === "products") {
      productSearch.style.display = "block";
    }
  } else if (tableName && fieldName === "all") {
    searchResults();
  }
}

function searchSpecific(id) {
  specificValue = document.getElementById(id);
  fieldValue = specificValue.value;
  searchResults();
}

function searchProductWiseClients(product) {
  productValue = product.value;
  searchResults();
}

function searchResults() {
  fetch(url + "/search_results", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      table: tableName,
      field: fieldValue,
      product_name: productValue,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      displaySearchResults(data);
    })
    .catch((error) => {
      if (error instanceof TypeError) {
        return;
      }
      console.error(error);
    });
}

function displaySearchResults(data) {
  console.log(data)
  searchResultsDiv.style.display = "block";
  rows = data?.length;
  cols = data[0]?.length;

  if (!rows) {
    alert("No such entries found!");
    resetValues();
  }
  let infoRow= document.createElement("tr");
  let headerRow = document.createElement("tr");
  if (tableName === "employees") {
    headerRow.innerHTML = `<th>Sr No.</th><th>Employee Id</th><th>First Name</th><th>Last Name</th><th>Email</th><th>Address</th><th>Department ID</th><th>Role ID</th><th>Created At</th>`;
    
  } else if (tableName === "clients") {
    headerRow.innerHTML = `<th>Sr no.</th><th>Client ID</th><th>Client Name</th><th>Contact Number</th><th>Address</th><th>Created At</th>`;

    fetch(url + "/product_list", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then((product_data) => {
        for (let i = 0; i < data.length; i++) {
          for (let j = 0; j < product_data.length; j++) {
            if (data[i][4] == product_data[j][0]) {
              data[i][4] = product_data[j][1];
            }
          }
        }

        // for (let i = 0; i < rows; i++) {
        //   let rowDiv = document.createElement("tr");
        //   for (let j = 0; j < cols; j++) {
        //     let cell = document.createElement("td");
        //     cell.innerText = data[i][j];
        //     rowDiv.appendChild(cell);
        //   }
        //   searchResultsDiv.appendChild(rowDiv);
        // }
        resetValues();
      })
      .catch((error) => {
        console.error(error);
      });
  } else if (tableName === "products") {
    headerRow.innerHTML = `<th>ID</th><th>Product ID</th><th>Model Number</th><th>Product Name</th><th>File Name</th><th>creation_time</th>`;
  searchResultsDiv.appendChild(headerRow);
      for (let i = 0; i < rows; i++) {
        let rowDiv = document.createElement("tr");
        for (let j = 0; j < cols; j++) {
          let cell = document.createElement("td");
          if(j==4 && data[i][j]!==null){
            cell.innerHTML=`<a href="${url}/get_doc_path/${data[i][j]}" target="_blank">${data[i][j]}</a>`;
          }
          else{
            cell.innerText = data[i][j];
          }
          rowDiv.appendChild(cell);
        }
        searchResultsDiv.appendChild(rowDiv);
      }
      resetValues();
      return;
    // })
  } else if (tableName === "productWiseClients") {
    infoRow.innerHTML=`<td colspan="4">Clients using the product: ${productValue}</td>`
    searchResultsDiv.appendChild(infoRow);
    headerRow.innerHTML = `<th>Sr no.</th><th>Client ID</th><th>Client Name</th><th>Created At</th>`;

    for (let i = 0; i < data.length; i++) {
      data[i][4] = productValue;
    }
  }

  searchResultsDiv.appendChild(headerRow);

  if (tableName !== "clients" || tableName!== "products") {
    for (let i = 0; i < rows; i++) {
      let rowDiv = document.createElement("tr");
      for (let j = 0; j < cols; j++) {
        let cell = document.createElement("td");
        cell.innerText = data[i][j];
        rowDiv.appendChild(cell);
      }
      searchResultsDiv.appendChild(rowDiv);
    }
  }
  resetValues();
}

function resetValues() {
  const resetVars = [];
  tableName = null;
  tableSelect.value = "";
  productWiseClientsSearch.style.display = "none";
  productWiseClientsSearch.value = "";
  searchType.style.display = "none";
  searchType.value = "";
  fieldName = null;
  fieldValue = null;
  if (specificValue) {
    specificValue.value = "";
  }
  employeeSearch.style.display = "none";
  clientSearch.style.display = "none";
  productSearch.style.display = "none";
  specificValue = null;
}

signInForm.addEventListener("submit",function(event){
  event.preventDefault();
  const formData=new FormData(signInForm);
  const signInData={}
  for (const field of formData.entries()){
    signInData[field[0]]=field[1];
  }

  fetch(url+"/sign_in",{
    method:"POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(signInData),
  })
    .then((response) => response.json())
    .then((data) => {
      if(data.status==="success"){
        loggedIn=true;
        loggedInSection.style.display="block";
        passTestDiv.style.display="none";
      }
      else{
        signInMessage.innerText=data.status;
      }
    })
    .catch((error) => {
      console.error("Error:", error);
    });

  event.target.reset();
})

employeeForm.addEventListener("submit", function (event) {
  event.preventDefault();
  const formData = new FormData(employeeForm);
  const employeeData = {};
  for (const field of formData.entries()) {
    employeeData[field[0]] = field[1];
  }
  console.log(employeeData);

  fetch(url + "/new_employee", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(employeeData),
  })
    .then((response) => response.json())
    .then((data) => {
      alert(data.status);
    })
    .catch((error) => {
      console.error("Error:", error);
    });

  event.target.reset();
});

clientForm.addEventListener("submit", function (event) {
  event.preventDefault();
  const formData = new FormData(clientForm);
  const clientData = {};
  for (const field of formData.entries()) {
    clientData[field[0]] = field[1];
  }
  console.log(clientData);

  fetch(url + "/new_client", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(clientData),
  })
    .then((response) => response.json())
    .then((data) => {
      alert(data.status);
    })
    .catch((error) => {
      console.error("Error:", error);
    });

  event.target.reset();
});

productForm.addEventListener("submit", function (event) {
  event.preventDefault();
  const formData = new FormData(productForm);
  const files=document.getElementById('productFileUpload')
  const productData = {};
  for (const field of formData.entries()) {
    productData[field[0]] = field[1];
  }

  const sendData=new FormData()
  sendData.append('data',JSON.stringify(productData))
  sendData.append('productFile',files.files[0])
  console.log(sendData);

  fetch(url + "/new_product", {
    method: "POST",
    body: sendData,
  })
    .then((response) => response.json())
    .then((data) => {
      alert(data.status);
    })
    .catch((error) => {
      console.error("Error:", error);
    });

  event.target.reset();
});
