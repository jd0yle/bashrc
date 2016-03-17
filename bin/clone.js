#!/usr/bin/node
(function(){
    "use strict";
    var sourceVmName,
        targetVmName,
        targetHostname,
        targetStaticIp,
        vmProcess;
    var scriptDir = require("path").dirname(process.mainModule.filename);

    var showHelp = function(exitCode){
        console.log("Error: Invalid Arguments");
        console.log("USAGE: clone sourceVmName targetVmName targetHostname targetStaticIp");
        if (exitCode !== undefined){
            process.exit(exitCode);
        }
    };




    var cloneVm = function(callback){
        callback = typeof callback === "function" ? callback : function(){};
        var child = require("child_process").spawn(
            "VBoxManage",
            ["clonevm", sourceVmName,
            "--name", targetVmName,
            "--register"],
            {stdio: "inherit"}
        );

        child.on("exit", function (code) {
            if (code !== 0){
                process.exit(-1);
            }
            callback();
        });

        process.on("exit", function(){
            child.kill();
        });
    };

    var getIpAddress = function(){
        var fs = require("fs"),
            hosts,
            regex = /192.168.56.(\d+)/gi,
            match,
            maxIp = 0;
        hosts = fs.readFileSync("/etc/hosts", "utf-8");

        while(match = regex.exec(hosts)){
            if (match !== undefined && match[1] !== undefined){
                if (parseInt(match[1], 10) >= parseInt(maxIp, 10)){
                    maxIp = parseInt(match[1], 10) + 1;
                }
            }
        }
        if (maxIp === 0){
            maxIp = 160;
        }
        return "192.168.56." + maxIp;
    };

    var startVm = function(callback){
        callback = typeof callback === "function" ? callback : function(){};
        vmProcess = require("child_process").spawn(
            "VBoxHeadless",
            ["-s", targetVmName],
            {stdio: "inherit"}
        );

        vmProcess.on("exit", function (code) {
            if (code !== 0){
                process.exit(-1);
            }
            callback();
        });

        process.on("exit", function(){
            //vmProcess.kill();
        });
    };

    var setIpAddress = function(callback){
        callback = typeof callback === "function" ? callback : function(){};
        var child,
            fs = require("fs"),
            interfacesContent = "# interfaces(5) file used by ifup(8) and ifdown(8) \n\
                auto lo \n\
                iface lo inet loopback \n\
                auto eth0  \n\
                iface eth0 inet dhcp \n\
                auto eth1 \n\
                iface eth1 inet static \n\
                address " + targetStaticIp + " \n\
                netmask 255.255.255.0 \n\
                #gateway 10.0.2.0 \n\
                dns-nameservers 8.8.8.8 8.8.4.4 192.168.0.10 192.168.0.6";

        fs.writeFileSync("interfaces", interfacesContent, "utf-8");

        console.log("Setting ip address");

        child = require("child_process").spawn(
            "scp",
            ["interfaces", "root@192.168.56.168:/etc/network/interfaces"],
            {stdio: "inherit"}
        );

        child.on("exit", function (code) {
            if (code !== 0){
                process.exit(-1);
            }
            console.log("Ip address set");
            callback();
        });

        process.on("exit", function(){
            child.kill();
        });
    };

    var setHostname = function(callback){
        var setHostsFile = function(callback){
            callback = typeof callback === "function" ? callback : function(){};
            var child,
                fs = require("fs"),
                hosts;

            console.log("Setting hosts");

            hosts = fs.readFileSync("/etc/hosts", "utf-8");
            hosts = hosts + "\n" + targetStaticIp + "   " + targetHostname;
            fs.writeFileSync(scriptDir + "/hosts", hosts);
            hosts = hosts.replace(/192\.168\.56\.140/gi, targetStaticIp);
            fs.writeFileSync("" + scriptDir + "/hosts.tmp", hosts);

            require("child_process").exec("sudo cp " + scriptDir + "/hosts /etc/hosts", function(err, stdout, stderr){
                if (err){
                    console.log(stdout);
                    console.log(stderr);
                    throw(err);
                }
                console.log("Copied new hosts file to local /etc/hosts");
                console.log(stdout);
            });

            console.log(hosts);

            child = require("child_process").spawn(
                "scp",
                [scriptDir + "/hosts.tmp", "root@192.168.56.168:/etc/hosts"],
                {stdio: "inherit"}
            );

            child.on("exit", function (code) {
                if (code !== 0){
                    process.exit(-1);
                }
                console.log("hosts set");
                callback();
            });

            process.on("exit", function(){
                child.kill();
            });
        };

        var setHostnameFile = function(callback){
            callback = typeof callback === "function" ? callback : function(){};

            console.log("Setting hostname file");

            require("child_process").exec("ssh root@192.168.56.168 \"echo \"" + targetHostname + "\" > /etc/hostname\"", function(err, stdout, stderr){
                if(err){
                    console.log(stderr);
                    throw(err);
                }
                console.log(stdout);
                console.log("hostname file set");
                callback();
            });
        };

        var setHostnameRuntime = function(callback){
            callback = typeof callback === "function" ? callback : function(){};

            console.log("Setting hostname");

            require("child_process").exec("ssh root@192.168.56.168 \"hostname " + targetHostname + "\"", function(err, stdout, stderr){
                if(err){
                    console.log(stderr);
                    throw(err);
                }
                console.log(stdout);
                console.log("hostname set");
                callback();
            });
        };

        setHostsFile(function(){
            setHostnameFile(function(){
                setHostnameRuntime(callback);
            });
        });
    };

    var rebootVm = function(callback){
        callback = typeof callback === "function" ? callback : function(){};
        var child;

        console.log("Rebooting");

        child = require("child_process").spawn(
            "ssh",
            ["root@192.168.56.168", "reboot"],
            {stdio: "inherit"}
        );

        child.on("exit", function (code) {
            callback();
        });
    };

    var createVm = function(callback){
        cloneVm(function(){
            startVm();
            setTimeout(function(){
                var ip = getIpAddress();
                console.log(ip);
                setHostname(function(){
                    setIpAddress(function(){
                        rebootVm(callback);
                    });
                });
            }, 10000);
        });
    };

    var ssh = function(callback){
        callback = typeof callback === "function" ? callback : function(){};
        vmProcess = require("child_process").spawn(
            "ssh",
            [targetVmName],
            {stdio: "inherit", detached: true}
        );

        vmProcess.on("exit", function (code) {
            callback();
        });

        process.on("exit", function(){
            //vmProcess.kill();
        });
    };

    var executeRemote = function(callback){
        var child;
        require("child_process").exec("echo $SSH_CLIENT", function(err, sshClient, stderr){
            var regex = /^(\d+\.\d+\.\d+\.\d+)/g,
                ip;
            var match = regex.exec(sshClient);
            if (match !== undefined && match !== null && match[1] !== undefined){
                ip = match[1];
                child = require("child_process").spawn(
                    "ssh " + ip + " \"" + process.argv[0] + "\"",
                    [],
                    {stdio: "inherit"}
                );

                child.on("exit", function (code) {
                    process.exit(-1);
                });

                process.on("exit", function(){
                    //child.kill();
                });
            }
        });
    };

    sourceVmName = process.argv[2] || showHelp(-1);
    targetVmName = process.argv[3] || showHelp(-1);
    targetHostname = process.argv[4] || targetVmName;
    targetStaticIp = process.argv[5] || getIpAddress();

    if (require("os").hostname() !== "jdoylemac.djicorp.donjohnston.com" && require("os").hostname() !== "004167LT-Justin-Doyle.local"){
        executeRemote(function(){
            setTimeout(function(){
                console.log("Done!");
                process.exit(0);
            }, 3000);
        });
    } else {
        createVm(function(){
            setTimeout(function(){
                console.log("Done!");
                process.exit(0);
               /* ssh();
                setTimeout(function(){
                    console.log("Done!");
                    process.exit(0);
                }, 2000);*/
            }, 8000);
        });
    }

})();
