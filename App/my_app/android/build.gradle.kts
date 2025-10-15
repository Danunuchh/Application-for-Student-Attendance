import org.gradle.api.file.Directory
import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ย้ายโฟลเดอร์ build ตามที่คุณตั้งไว้เดิม
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

/* =========================
   ตั้งค่า JVM ให้ “นิ่ง” ทั้งโปรเจกต์
   ========================= */
//
// 1 ค่ามาตรฐาน: ทุกโมดูล = Java/Kotlin 17
//
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        // ห้ามใช้ options.release บน Android → ใช้ source/target เท่านั้น
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
        // ลด noise คำเตือน options เก่า ๆ
        options.compilerArgs.add("-Xlint:-options")
    }
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "17"
    }
}

//
// 2 ยกเว้น “เฉพาะ” โมดูลที่ยังคอมไพล์ Java 1.8 ให้ Kotlin ลงมา 1.8 ให้ตรงกัน
//    ตอนนี้พบปัญหาที่ mobile_scanner
//
project(":mobile_scanner") {
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "1.8"
    }
    // ไม่แตะ JavaCompile ของโมดูลนี้ → ให้คง 1.8 ตามปลั๊กอิน
}

// (ถ้าพบปลั๊กอินอื่นยังใช้ Java 1.8 ให้ copy บล็อกด้านล่างนี้ไปเปลี่ยนชื่อโมดูล)
// project(":ชื่อโมดูล") {
//     tasks.withType<KotlinCompile>().configureEach {
//         kotlinOptions.jvmTarget = "1.8"
//     }
// }
