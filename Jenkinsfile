pipeline {

    agent none

    stages {

        // temporary, in the future we should not build the application here
        stage('Build QMSTR') {
            agent {
                docker { image 'endocode/qmstr_buildenv:latest' }
            }
            steps {
                sh "make clients"
                stash includes: 'out/qmstr*', name: 'executables' 
                archiveArtifacts artifacts: 'out/*', fingerprint: true
            }
            
        }

        // as soon as the master branch of qmstr is built by the CI and creates artifacts,
        // these binaries should be imported to the following jobs
        stage('Compile with QMSTR'){
            parallel{

                stage('compile curl'){

                    environment {
                        PATH = "$PATH:$WORKSPACE/out/"
                    }

                    agent { label 'docker' }

                    steps {
                        unstash 'executables'
                        sh 'make container'
                        sh 'git submodule update --init'
                        sh "cd demos && make curl"
                       
                    }
                }

                stage('compile openssl'){

                    agent { label 'docker' }

                    environment {
                        PATH = "$PATH:$WORKSPACE/out/"
                    }

                    steps {
                        unstash 'executables'
                        sh 'make container'
                        sh 'git submodule update --init'
                        sh "cd demos && make openssl"
                    }
                }
            }
        }
        // stage('Publish report') {
        //     steps {
        //         dir("web"){
        //             withEnv(["PATH+SNAP=/snap/bin"]){
        //                 sh 'git submodule init && git submodule update'
        //                 sh 'cp ${WORKSPACE}/qmstr-demo/demos/curl/qmstr-reports.tar.bz2 ./'
        //                 sh '(cd ./static && tar xvjf ../qmstr-reports.tar.bz2 && mv ./reports ./packages)'
        //                 sh './scripts/generate-data-branch.sh ./tempfolder'
        //                 sh 'git config http.sslVersion tlsv1.2'
        //                 withCredentials([usernamePassword(credentialsId: '6374572f-c47a-4939-beda-2ee601d65ff7', passwordVariable: 'cipassword', usernameVariable: 'ciuser')]) {
        //                     //sh 'git push --force https://${ciuser}:${cipassword}@github.com/qmstr/web gh-pages'  
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}
