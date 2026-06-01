alert("menu carregado");

const botaoMenu =
document.getElementById("menuFuncionalidades");

const submenu =
document.getElementById("submenuFuncionalidades");

console.log(botaoMenu);
console.log(submenu);

botaoMenu.addEventListener("click", function(e){

    e.preventDefault();

    submenu.classList.toggle("show");

});