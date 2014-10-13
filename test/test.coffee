assert = require 'assert'
linear = require '../linear.js'

describe 'Helper functions', ->
    describe 'zipWith', ->
        it 'should zip two lists with an operator', ->
            assert.deepEqual (linear._zipWith [1, 2, 3], [4, 5, 6], ((a, b) -> a + b)),
                             [1 + 4, 2 + 5, 3 + 6]
    describe 'sum', ->
        it 'should add things', ->
            assert.equal (linear._sum [1, 2, 3]), 1 + 2 + 3

    describe 'prod', ->
        it 'should multiply things', ->
            assert.equal (linear._prod [1, 2, 3]), 1 * 2 * 3

    describe 'generalizedScale', ->
        it 'should scale a scalar', ->
            assert.equal linear._generalizedScale(5, 2), 10
        it 'should scale a vector', ->
            assert.equal linear._generalizedScale(new linear.Vector(5), 2).data, 10

describe 'Vector', ->
    v0 = new linear.Vector(1, 1, 1)
    v1 = new linear.Vector(1, 2)
    v2 = new linear.Vector(3, 4)
    v3 = new linear.Vector(1, 2, 3)

    it 'can be constructed', ->
        assert.deepEqual v1.data, linear.Vector.fromArray([1, 2]).data
    it 'can be 2d', ->
        assert.equal v1.data[0], 1
        assert.equal v1.data[1], 2
    it 'can be 3d', ->
        assert.equal v3.data[2], 3
    it 'should have length', ->
        assert.equal v0.length(), Math.sqrt(3)
    it 'should have units', ->
        i = linear.Vector.i()
        assert.deepEqual i.data, [1, 0, 0]
        j = linear.Vector.j()
        assert.deepEqual j.data, [0, 1, 0]
        k = linear.Vector.k()
        assert.deepEqual k.data, [0, 0, 1]
    it 'can be cloned', ->
        v3_prime = v3.clone()
        assert.deepEqual v3_prime.data, v3.data
        v3_prime.data[0] = 100
        assert.notEqual v3_prime.data[0], v3.data[0]
    it 'can be negated', ->
        v1_neg = new linear.Vector(-1, -2)
        assert.deepEqual v1.negate().data, v1_neg.data
    it 'can be added', ->
        assert.deepEqual v1.plus(v2).data, (new linear.Vector(1 + 3, 2 + 4)).data
    it 'can be subtracted', ->
        assert.deepEqual v1.minus(v2).data, (new linear.Vector(1 - 3, 2 - 4)).data
    it 'can be scaled', ->
        assert.deepEqual v1.scale(5).data, (new linear.Vector(1 * 5, 2 * 5)).data

    describe 'products', ->
        it 'should have a dot product', ->
            v1 = new linear.Vector(1, 2, 3)
            v2 = new linear.Vector(5, 6, 7)
            assert.equal v1.dot(v2), 38
        it 'should have a cross product', ->
            i = linear.Vector.i()
            j = linear.Vector.j()
            k = linear.Vector.k()

            assert.deepEqual i.cross(j), k
            assert.deepEqual j.cross(k), i
            assert.deepEqual k.cross(i), j

            assert.deepEqual j.cross(i), k.negate()

describe 'Matrix', ->
    m1 = new linear.Matrix(
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    )
    m2 = new linear.Matrix(
        [2, 0],
        [0, 1]
    )
    m3 = new linear.Matrix(
        [2, 3],
        [5, 7]
    )
    it 'can be constructed', ->
        assert.deepEqual m1.data, linear.Matrix.fromArray([
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]).data
        assert.equal typeof linear.Matrix.fromArray(m1.data).transpose, 'function'
    it 'should be square', ->
        assert.equal m1.data[0][0], 1
        assert.equal m1.data[0][1], 2
        assert.equal m1.data[0][2], 3
        assert.equal m1.data[1][0], 4
    it 'can be transposed', ->
        assert.deepEqual m1.transpose().data, [
            [1, 4, 7],
            [2, 5, 8],
            [3, 6, 9]
        ]
    it 'can be added', ->
        assert.deepEqual m2.plus(m3).data, [
            [4, 3],
            [5, 8]
        ]
    it 'can be negated', ->
        assert.deepEqual m2.negate().data, [
            [-2, 0],
            [0, -1]
        ]
    it 'can be subtracted', ->
        assert.deepEqual m2.minus(m3).data, [
            [0, -3],
            [-5, -6]
        ]
    it 'can be multiplied', ->
        a = new linear.Matrix(
            [1, 2, 3],
            [4, 5, 6]
        )
        b = new linear.Matrix(
            [7, 8],
            [9, 10],
            [11, 12]
        )
        assert.deepEqual a.times(b).data, [[58, 64], [139, 154]]
    it 'should have minors', ->
        assert.deepEqual m1.minor(0, 2).data, [
            [4, 5],
            [7, 8]
        ]
        assert.equal m1.data[2][2], 9
        assert.equal typeof m1.minor(0, 2).minor, 'function'
    it 'can be cloned', ->
        m1_prime = new linear.Matrix(
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        )
        assert.deepEqual m1.data, m1_prime.data
        m1_prime.data[0][0] = 100
        assert.notEqual m1.data[0][0], m1_prime.data[0][0]
    it 'should have a determinant', ->
        assert.equal new linear.Matrix([1]).det(), 1
        assert.equal m1.det(), 0
        assert.equal m2.det(), 2

        generalizedM = new linear.Matrix(
            [linear.Vector.i(), linear.Vector.j()],
            [0, 1],
        )
        assert.deepEqual generalizedM.det().data, linear.Vector.i().data
