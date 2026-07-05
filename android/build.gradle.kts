allprojects {
    repositories {
        google()
        mavenCentral()
        // Unity ships arcore_client / UnityARCore / ARPresto / openxr_loader as loose
        // .aar files under unityLibrary/libs — resolved via flatDir (T4.4).
        flatDir { dirs(file("$rootDir/unityLibrary/libs")) }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
