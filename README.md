# AutoScholarship

AutoScholarship is a Solidity smart contract that automates scholarship disbursement based on student CGPA. Sponsors can create scholarships with target CGPA requirements, and funds are automatically released to students who meet the targets. Admins can update student CGPA and refund scholarships if needed.

---

## Step 1: Install Required Tools

1. **MetaMask:** [https://metamask.io/](https://metamask.io/) → Create a wallet.  
2. **Ganache:** [https://trufflesuite.com/ganache/](https://trufflesuite.com/ganache/) → Local blockchain with test ETH.  
3. **Remix IDE:** [https://remix.ethereum.org/](https://remix.ethereum.org/) → Solidity compiler & deployer.  
4. **Git:** [https://git-scm.com/](https://git-scm.com/) → For version control and GitHub push.

---

## Step 2: Set Up Ganache & MetaMask

1. Open Ganache → Copy RPC URL (default: `http://127.0.0.1:7545`).  
2. Copy a private key → Import into MetaMask.  
3. Add a custom network in MetaMask:  
   - Network Name: `Ganache Local`  
   - RPC URL: `http://127.0.0.1:7545`  
   - Chain ID: `1337`  
   - Currency: `ETH`  
4. Switch MetaMask to this network.

---

## Step 3: Deploy Contract

1. Open Remix → Create `AutoScholarship.sol` in `contracts/`.  
2. Paste the Solidity code from the cleaned contract.  
3. Compile with **Solidity 0.8.19**.  
4. Deploy:  
   - Environment → **Injected Web3** (connects to MetaMask)  
   - Select `AutoScholarship` → Click **Deploy** → Confirm in MetaMask.  
5. Save the contract address for reference.

---

## Step 4: Interact With Contract

### Create Scholarship
- Function: `createScholarship(_student, _targetCgpa)`  
- Value: ETH amount for scholarship  
- Confirm in MetaMask  
- Scholarship auto-releases if student already meets CGPA

### Update Student CGPA (Admin Only)
- Function: `updateCgpa(_student, _newCgpa)`  
- Automatically releases scholarships that meet target CGPA

### Refund Scholarship (Admin Only)
- Function: `refundScholarship(_scholarshipId)`  
- Returns ETH to sponsor if not yet released

### View Data
- `getScholarship(id)` → Returns Scholarship details  
- `getStudentCgpa(address)` → Returns student CGPA

---

## Step 5: Verify Transactions

- Check MetaMask → ETH balances  
- Remix → Contract outputs and events

---

## Step 6: Events

- `ScholarshipCreated` → Emitted when a scholarship is created  
- `CgpaUpdated` → Emitted when a student’s CGPA is updated  
- `FundsReleased` → Emitted when scholarship funds are released  
- `FundsRefunded` → Emitted when funds refunded to the sponsor

---

## Step 7: Security Notes

- Uses `call` with zeroing out amount to prevent reentrancy  
- Only admin can update CGPA and refund scholarships  
- Ensure CGPA is scaled properly (multiply by 100)  

---

## License

MIT License
