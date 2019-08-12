
const { toHex } = web3.utils;
const Remittance = artifacts.require('./Remittance.sol');

contract('Remittance', accounts => {
    const [alice, carol, randomAddress] = accounts;
    let remittanceInstance, hashedCombo, txObj;

    beforeEach("create new instance", async () => {
        remittanceInstance = await Remittance.new({ from: alice });
        hashedCombo = await remittance.generateHashedCombo(toHex("password"), carol);
        txObj = await remittanceInstance.deposit(hashedCombo, 172800, { from: alice, value: 10 });
    });

    it('depositFunds', async () => {
        const remittance = await remittanceInstance.remittances.call(hashedCombo);
        const log = txObj.logs[0];
        assert.strictEqual(remittance.amount.toString(10), "10");
        assert.strictEqual(remittance.originalSender, alice);
        assert.strictEqual(remittance.expiration.toString(10), "172800");
        assert.strictEqual(log.event, "LogDeposit");
        assert.strictEqual(log.args[0], alice);
        assert.strictEqual(log.args[0], "10");
        assert.strictEqual(log.args[0], hashedCombo);
    });

    it('withdrawFunds', async () => {
        try {
            const balanceBefore = await web3.eth.getBalance(carol);
            const txObj = await remittance.withdrawFunds(toHex("password"), { from: carol });
            const log = txObj.logs[0];
            const gasUsed = txObj.receipt.gasUsed
            const hash = txObj.receipt.transactionHash;
            const tx = await web3.eth.getTransactionPromise(hash);
            const gasPrice = tx.gasPrice;
            const txFee = gasUsed * gasPrice;
            const balanceNow = await web3.eth.getBalancePromise(carol);

            const remittance = await remittanceInstance.remittances.call(hashedCombo);
            assert.strictEqual(remittance.amount.toString(10), "0");
            assert.strictEqual(balanceNow.toString(10), balanceBefore.plus(10).minus(txFee).toString(10), "wrong balance");
            assert.strictEqual(log.event, "LogWithdrawal");
            assert.strictEqual(log.args[0], carol);
            assert.strictEqual(log.args[0], "10");
            assert.strictEqual(log.args[0], hashedCombo);
        }
    });

    it('refundFunds', async () => {
        try {
            await remittance.refund(hashedCombo, { from: randomAddress });
        }

        // figure out how to send date to make this fail
    });
});