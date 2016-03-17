#!/usr/bin/env node
/**
 * lookup-ec2-instance.js
 * Project: aws
 * Description:
 * Creator: Justin Doyle <justin@jmdoyle.com>
 * Date: 1/14/2016
 */
module.exports = (function () {
    "use strict";
    /**************************************************************************
     * V A R I A B L E S
     ***************************************************************************/
    var commander = require("commander"),
        AWS = require("aws-sdk");
    var that = {},
        ec2;

    AWS.config.loadFromPath(process.env.HOME + "/.prompt/etc/credentials/aws.json");

    ec2 = new AWS.EC2();

    var parseArgs = function () {
        commander
            .version(require(process.env.HOME + "/.prompt/package.json").version)
            .option("-n, --name <name>", "EC2 Instance name", false)
            .option("-k, --key", "Retrieve the ssh key used for the instance")
            .parse(process.argv);

        if (!commander.name) {
            commander.help();
        }
    };

    that.getIpAddress = function (instanceName, callback) {
        callback = typeof callback === "function" ? callback : function () {};
        var params = {
            Filters: [
                {
                    Name: "tag-value",
                    Values: [instanceName]
                }
            ]
        };
        ec2.describeInstances(params, function (err, data) {
            var ipAddress;
            if (err) {
                throw(err);
            }
            // console.log(JSON.stringify(data, null, 4));
            ipAddress = data
                .Reservations[0]
                .Instances[0]
                .PublicIpAddress;

            callback(ipAddress);
        });
    };

    that.getKeyName = function (instanceName, callback) {
        callback = typeof callback === "function" ? callback : function () {};
        var params = {
            Filters: [
                {
                    Name: "tag-value",
                    Values: [instanceName]
                }
            ]
        };
        ec2.describeInstances(params, function (err, data) {
            var keyName;
            if (err) {
                throw(err);
            }
            // console.log(JSON.stringify(data, null, 4));
            keyName = data
                .Reservations[0]
                .Instances[0]
                .KeyName;

            callback(keyName);
        });
    };

    if (require.main === module) {
        // Script was called directly from command line, so send the repos to stdout
        parseArgs();
        if (commander.key) {
            that.getKeyName(commander.name, function (keyName) {
                console.log(keyName); // eslint-disable-line no-console
            });
        } else {
            that.getIpAddress(commander.name, function (ipAddress) {
                console.log(ipAddress); // eslint-disable-line no-console
            });
        }
    } else {
        // If the script was required by another script as a module,
        // make sure we return the object to the requiring script
        return that;
    }
})();
