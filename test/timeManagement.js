const { expect } = require('chai');

function timeConverter(UNIX_timestamp){
    var a = new Date(UNIX_timestamp * 1000);
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var year = a.getFullYear();
    var month = months[a.getMonth()];
    var date = a.getDate();
    var hour = a.getHours();
    var min = a.getMinutes();
    var sec = a.getSeconds();
    var time = date + ' ' + month + ' ' + year + ' ' + hour + ':' + min + ':' + sec ;
    return time;
}

const oneDay = 24 * 60 * 60;

function addDays(numOfDays, date) {
    tmpDate = date + numOfDays * oneDay;
    return tmpDate;
}

function timePasses(secondsNumber) {
    it('time machine in action', async function () {
        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        const timestampBefore = blockBefore.timestamp;
        console.log("Block number now: " + blockNumBefore + ", and time now: "+ timeConverter(timestampBefore).toString())

        await ethers.provider.send('evm_increaseTime', [secondsNumber]);
        await ethers.provider.send('evm_mine');

        const blockNumAfter = await ethers.provider.getBlockNumber();
        const blockAfter = await ethers.provider.getBlock(blockNumAfter);
        const timestampAfter = blockAfter.timestamp;

        // expect(blockNumAfter).to.be.equal(blockNumBefore + 1);
        // expect(timestampAfter).to.be.equal(timestampBefore + secondsNumber);

        console.log("... after " + secondsNumber + " seconds or " + secondsNumber / oneDay + " days ...");
        console.log("new Block number now: " + blockNumAfter + ", and new time now: "+ timeConverter(timestampAfter).toString())
    });
}

module.exports = {
    timeConverter,
    addDays,
    timePasses
}