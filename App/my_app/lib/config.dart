// สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
// สำหรับ Physical Device ใช้ IP ของเครื่องคอมพิวเตอร์ เช่น 192.168.1.100
// สำหรับ iOS Simulator / Web ใช้ localhost ได้
// N: ลบ /Services ออก เพราะ Docker mount ./Services -> /var/www/html (document root)
// const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator

const String baseUrl = 'http://192.168.0.113:8000/Services/'; // Physical Device (เปลี่ยน IP ตามเครื่องคุณ)

// const String baseUrl = 'http://localhost:8000'; // Physical Device (เปลี่ยน IP ตามเครื่องคุณ)
// //const String baseUrl = 'http://192.168.1.64:8000'; // Physical Device (เปลี่ยน IP ตามเครื่องคุณ)

// const String baseUrl = 'http://172.19.176.1:8000'; // Physical Device (เปลี่ยน IP ตามเครื่องคุณ)

// // const String baseUrl = 'http://localhost:8000'; // iOS Simulator / Web

