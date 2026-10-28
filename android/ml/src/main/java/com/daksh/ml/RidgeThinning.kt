package com.daksh.ml

import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.imgproc.Imgproc

object RidgeThinning {
    private val neighbors = arrayOf(
        intArrayOf( 0, -1), intArrayOf( 1, -1), intArrayOf( 1,  0),
        intArrayOf( 1,  1), intArrayOf( 0,  1), intArrayOf(-1,  1),
        intArrayOf(-1,  0), intArrayOf(-1, -1), intArrayOf( 0, -1)
    )

    private val neighborsGroups = arrayOf(
        arrayOf(intArrayOf(0, 2, 4), intArrayOf(2, 4, 6)),
        arrayOf(intArrayOf(0, 2, 6), intArrayOf(0, 4, 6))
    )

    fun thinImage(mat: Mat) : Mat {
        val toWhite = mutableListOf<Point>()

        val rows = mat.rows()
        val cols = mat.cols()

        val binary = Mat()
        Imgproc.threshold(mat, binary, 127.0, 255.0, Imgproc.THRESH_BINARY)

        var firstStep = false
        var hasChanged: Boolean
        do {
            hasChanged = false
            firstStep = !firstStep
            for (r in 1 until rows - 1) {
                for (c in 1 until cols - 1) {
                    if (binary.get(r, c)[0] == BLACK) continue
                    val nn = numNeighbors(binary, r, c)
                    if (nn !in 2..6) continue
                    if (numTransitions(binary, r, c) != 1) continue
                    val step = if (firstStep) 0 else 1
                    if (!atLeastOneIsWhite(binary, r, c, step)) continue
                    toWhite.add(Point(c.toDouble(), r.toDouble()))
                    hasChanged = true
                }
            }
            for (p in toWhite) {
                binary.put(p.y.toInt(), p.x.toInt(), BLACK)
            }
        } while (firstStep || hasChanged)

        val convert = Mat()
        binary.convertTo(convert, CvType.CV_32F)
        return convert
    }

    private fun numNeighbors(mat: Mat, r: Int, c: Int) : Int {
        var count = 0
        for (i in 0 until neighbors.size - 1) {
            if (mat.get(r + neighbors[i][1], c + neighbors[i][0])[0] == WHITE) count++
        }
        return  count
    }

    private fun numTransitions(mat: Mat, r: Int, c: Int): Int {
        var count = 0
        for (i in 0 until neighbors.size - 1) {
            if (mat.get(r + neighbors[i][1], c + neighbors[i][0])[0] == BLACK) {
                if (mat.get(r + neighbors[i + 1][1], c + neighbors[i + 1][0])[0] == WHITE) count ++
            }
        }
        return count
    }

    private fun atLeastOneIsWhite(mat: Mat, r: Int, c: Int, step: Int): Boolean {
        var count = 0
        val group = neighborsGroups[step]
        for (i in 0..1) {
            for (j in 0 until group[i].size) {
                val nbr = neighbors[group[i][j]]
                if(mat.get(r + nbr[1], c + nbr[0])[0] == BLACK) {
                    count++
                    break
                }
            }
        }
        return count > 1
    }

    private const val BLACK = 0.0
    private const val WHITE = 255.0
}