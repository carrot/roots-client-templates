var chai = require('chai'),
    path = require('path'),
    chai_promise = require('chai-as-promised');

chai.should();
chai.use(chai_promise);

global.chai = chai;
global.base_path = path.join(__dirname, '../fixtures')
