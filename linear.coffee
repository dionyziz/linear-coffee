_ = require 'lodash'

EPSILON = 0.000000000001

plus = (a, b) -> a + b
negate = (a) -> -a
times = (a, b) -> a * b
scale = _.curry(times)
square = (x) -> x * x
sum = (l) -> _.reduce(l, plus)
prod = (l) -> _.reduce(l, times)
    
zipWith = (l1, l2, op) ->
    _.zip(l1, l2).map (pair) ->
        op(pair[0], pair[1])

applyNew = (constructor, args) ->
    F = -> constructor.apply this, args
    F.prototype = constructor.prototype
    new F

assert = (cond) ->
    if not cond
        throw 'Assertion failed'

sigma = (i) -> 1 - 2 * (i % 2)

almostEqual = (a, b) ->
    Math.abs(a - b) < EPSILON

class Vector
    constructor: (@data...) ->
    clone: ->
        Vector.fromArray @data
    negate: ->
        Vector.fromArray _.map(@data, negate)
    dot: (other) ->
        assert @data.length == other.data.length
        sum zipWith(@data, other.data, times)
    cross: (other) ->
        new Matrix(
            [Vector.i(), Vector.j(), Vector.k()]
            @data,
            other.data
        ).det()
    length: ->
        Math.sqrt _.reduce(_.map(@data, square), plus, 0)
    plus: (other) ->
        Vector.fromArray (zipWith @data, other.data, plus)
    minus: (other) ->
        generalizedMinus this, other
    scale: (scalar) ->
        Vector.fromArray _.map(@data, scale scalar)
    normalize: ->
        @scale 1 / @length()
    equal: (other) ->
        _.every _.zip(@data, other.data), (ab) ->
            almostEqual(ab[0], ab[1])
    @fromArray: (data) ->
        applyNew Vector, data
    @i: ->
        new Vector 1, 0, 0
    @j: ->
        new Vector 0, 1, 0
    @k: ->
        new Vector 0, 0, 1
    @base: (k, n) ->
        a = (0 for i in [1..n])
        a[k] = 1
        Vector.fromArray a

class Matrix
    constructor: (@data...) ->
    equal: (other) ->
        _.every _.zip(@toVectors(), other.toVectors()), (ab) ->
            ab[0].equal(ab[1])

    transpose: ->
        Matrix.fromArray _.map @data[0], (col, i) =>
            _.map @data, (row) -> row[i]
    plus: (other) ->
        Matrix.fromVectors (zipWith @toVectors(), other.toVectors(), generalizedPlus)
    negate: ->
        Matrix.fromVectors (_.map @toVectors(), generalizedNegate)
    minus: (other) ->
        generalizedMinus this, other
    scale: (scalar) ->
        Matrix.fromVectors (_.map @toVectors(), (v) -> v.scale(scalar))
    times: (other) ->
        rows = @toVectors()
        cols = other.transpose().toVectors()
        Matrix.fromArray _.map rows, (row) ->
                         _.map cols, (col) ->
                                      row.dot(col)
    det: ->
        if @data.length == 1
            return @data[0][0]
        generalizedSum _.map @data[0], (col, index) =>
            minorDet = @minor(0, index).det()
            inner = generalizedScale(col, sigma(index) * minorDet)
    minor: (i, j) ->
        m = @clone()
        reducedCol = _.map m.data, (row) ->
            row.splice j, 1
            row
        reducedCol.splice i, 1
        Matrix.fromArray reducedCol
    cofactors: () ->
        Matrix.fromArray _.map @data, (row, i) =>
                         _.map row, (col, j) =>
                               sigma(i + j) * @minor(i, j).det()
    inverse: () ->
        @cofactors().transpose().scale(1 / @det())
    clone: ->
        Matrix.fromArray _.clone(@data, true)
    toVectors: ->
        _.map @data, Vector.fromArray

    @unit: (n) ->
        Matrix.fromArray (Vector.base(i, n).data for i in [0..n - 1])
    @fromArray: (data) ->
        applyNew Matrix, data
    @fromVectors: (vectors) ->
        Matrix.fromArray (_.pluck vectors, 'data')

generalizedScale = (x, scalar) ->
    if typeof x.data == 'undefined'
        return x * scalar
    x.scale(scalar)

generalizedPlus = (a, b) ->
    if typeof a.data == 'undefined'
        return a + b
    a.plus(b)

generalizedNegate = (a) ->
    if typeof a.data == 'undefined'
        return -a
    a.negate()

generalizedMinus = (a, b) ->
    generalizedPlus a, generalizedNegate(b)

generalizedSum = (l) -> _.reduce(l, generalizedPlus)

module.exports._sum = sum
module.exports._prod = prod
module.exports._zipWith = zipWith
module.exports._generalizedScale = generalizedScale
module.exports._sigma = sigma
module.exports.Vector = Vector
module.exports.Matrix = Matrix
