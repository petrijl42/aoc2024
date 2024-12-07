#!/usr/bin/env node

const { match } = require("assert");
const fs = require("fs");
const path = require("path");

const input = fs.readFileSync(path.resolve(__dirname, "input2.txt"), "utf-8");

const operators = new Array("+", "*", "|");

const data = input
    .split("\n")
    .map((line) => {
        if (line === "") {
            return null;
        }
        const parts = line.split(" ");
        const total = parseInt(parts[0]);
        const numbers = parts.slice(1).map((n) => parseInt(n));
        return { total, numbers };
    })
    .filter((x) => x !== null);

// console.log(data);

var result = 0;

for (const { total, numbers } of data) {
    if (evaluate_equation(total, numbers, operators)) {
        result += total;
    }
}

console.log("Total result: ", result);

function evaluate_equation(total, numbers, operators) {
    var state = get_start_state(numbers.length - 1);
    do {
        var calculated_total = calculate_total(numbers, operators, state);

        if (calculated_total == total) {
            return true;
        }
    } while (increment_state(state, operators.length));

    return false;
}

function calculate_total(values, operators, state) {
    var index = 0;
    var total = values[index];

    for (const op of state) {
        index++;
        total = perform_calculation(total, values[index], operators[op]);
    }
    return total;
}

function perform_calculation(first, second, operator) {
    if (operator == "+") {
        return first + second;
    } else if (operator == "*") {
        return first * second;
    } else if (operator == "|") {
        return parseInt(first.toString() + second.toString());
    }
    return null;
}

function get_start_state(length) {
    return Array(length).fill(0);
}

function increment_state(state, base) {
    for (let i = state.length - 1; i >= 0; i--) {
        if (state[i] < base - 1) {
            state[i]++;
            return true;
        }
        state[i] = 0;
    }
    return false;
}
