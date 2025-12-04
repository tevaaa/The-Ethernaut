# My solutions for 'The Ethernaut' CTF challenges


[The Ethernaut by OpenZeppelin](https://ethernaut.openzeppelin.com/)
  
- Contracts source code are located in ```/src```, local test in ```/test``` and instances exploit in ```/script```

- **Launch tests**:```forge test [LevelName]```
- **Launch exploit**: First setup a ```.env``` file with your RPC and wallet key. Then run ->
```forge script [script_path] --rpc-url $SEPOLIA  --private-key $KEY --broadcast -vvv```

---

## Level 1 - Fallback (Vulnerability: Unrestricted Logic in Receive Function)

- **The root cause:** The receive allows to modify a critical state of the contract `owner = msg.sender` without the same check as in the `contribute()` function 
- -> if sender meets the required condition : ```contributions[msg.sender] > 0``` and ```msg.value > 0``` the owner becomes the message sender.

- **The exploit to take ownership is pretty straightforward:**
**1. Become a contributor** -> call `contribute()` with smallest amount valid (`>0`)
**2. Take ownership** -> send a pure ether tx without data at contract address to call the `receive()` function and executing the vulnerable line `owner = msg.sender`
**3. Call `withdraw()`** as the new owner as a proof we are owner now

---

## Level 2 - Fallout (Vulnerability: Misnamed Constructor)

- **The Root Cause:** The contract uses an outdated Solidity pattern where the constructor should have the same name as the contract (`Fallout`). However, the function intended to be the constructor is misnamed: `Fal1out()` (with a '1'). Crucially, the function **lacks the `constructor` keyword**.
- **The Consequence:** Because of the naming error and the missing `constructor` keyword, the `Fal1out()` function is treated by the compiler as a **regular public function** that can be called by **any external user** at any time after deployment.

- **The Exploit to Take Ownership:**
**1. Execute Pseudo-Constructor:** Call the public function `target.Fal1out()` once as the attacker (`msg.sender`).
**2. Take Ownership:** This call executes the critical line `owner = payable(msg.sender);`, assigning the attacker as the new contract owner.
**3. Validate:** Call `collectAllocations()` as the new `owner` to confirm control and drain the contract

## Level 4 - Telephone (Calling with another contract)
- The point off this level is to teach us how to call a function from a contract using another contract.
- tx.origin is the ```EOA``` Externally Owned Account the address that initiated the tx, and msg.sender the address that calls the function
**Solution:** Calling changeOwner() with another contract so that ```tx.origin != msg.sender```

## Level 5 - Token (Underflow)
**1. The Root Cause** The contract is using Solidity < 0.8.0. In those versions the mathematics operations on uint are not checked by the compiler. Developper must use external libs like SafeMath."

**2. 💥 The Consequence** Doing ```A - B``` where ```A < B``` doesnt induce revert but an ***underflow***. Exemple:
```
Uint A = 1;
A - 2; 
A -> MAXUint
 ```
 **3. The Exploit️ ⚔️:** Attacker interact with ```transfer()``` to induce the underflow and retrieve an absurd amount of token.
