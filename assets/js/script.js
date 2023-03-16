const currentDate = new Date();

const date = currentDate.toLocaleDateString();
const time = currentDate.toLocaleTimeString();

document.getElementById("date").textContent = `Current date is: ${date}`;
document.getElementById("time").textContent = `Current time is: ${time}`;
