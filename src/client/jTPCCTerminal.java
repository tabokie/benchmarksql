/*
 * jTPCCTerminal - Terminal emulator code for jTPCC (transactions)
 *
 * Copyright (C) 2003, Raul Barbosa
 * Copyright (C) 2004-2016, Denis Lussier
 * Copyright (C) 2016, Jan Wieck
 *
 */
import org.apache.log4j.*;

import java.io.*;
import java.sql.*;
import java.sql.Date;
import java.util.*;
import javax.swing.*;


public class jTPCCTerminal implements jTPCCConfig, Runnable
{
    private static org.apache.log4j.Logger log = Logger.getLogger(jTPCCTerminal.class);

	private boolean bulkReportMode = true;

    private String terminalName;
    private Connection conn = null;
    private Statement stmt = null;
    private Statement stmt1 = null;
    private ResultSet rs = null;
    private int terminalWarehouseID, terminalDistrictID;
    private int sourceBegin, sourceSize;
    private boolean terminalWarehouseFixed;
    private double paymentWeight, orderStatusWeight, deliveryWeight, stockLevelWeight;
    private int limPerMin_Terminal;
    private boolean plMode = false;
    private jTPCC parent;
    private jTPCCRandom rnd;

    private int transactionCount = 1;
    private int numTransactions;
    private int numWarehouses;
    private int targetBegin;
    private int targetSize;
    private int newOrderCounter;
    private long totalTnxs = 1;
    private StringBuffer query = null;
    private int result = 0;
    private boolean stopRunningSignal = false;

    long terminalStartTime = 0;
    long transactionEnd = 0;

    jTPCCConnection     db = null;
    int                 dbType = 0;

    public jTPCCTerminal
      (String terminalName, int terminalWarehouseID, int sourceBegin, int sourceSize, int terminalDistrictID,
       Connection conn, int dbType,
       int numTransactions, boolean terminalWarehouseFixed,
       double paymentWeight, double orderStatusWeight,
       double deliveryWeight, double stockLevelWeight, int numWarehouses, int targetBegin, int targetSize, int limPerMin_Terminal, boolean plMode,
       jTPCC parent) throws SQLException
    {
        this.terminalName = terminalName;
        this.conn = conn;
        this.dbType = dbType;
        this.stmt = conn.createStatement();
        this.stmt.setMaxRows(200);
        this.stmt.setFetchSize(100);

        this.stmt1 = conn.createStatement();
        this.stmt1.setMaxRows(1);

        this.terminalWarehouseID = terminalWarehouseID;
        this.sourceBegin = sourceBegin;
        this.sourceSize = sourceSize;
        this.terminalDistrictID = terminalDistrictID;
        this.terminalWarehouseFixed = terminalWarehouseFixed;
        this.parent = parent;
        this.rnd = parent.getRnd().newRandom();
        this.numTransactions = numTransactions;
        this.paymentWeight = paymentWeight;
        this.orderStatusWeight = orderStatusWeight;
        this.deliveryWeight = deliveryWeight;
        this.stockLevelWeight = stockLevelWeight;
        this.numWarehouses = numWarehouses;
        this.targetBegin = targetBegin;
        this.targetSize = targetSize;
        this.newOrderCounter = 0;
        this.limPerMin_Terminal = limPerMin_Terminal;
        this.plMode = plMode;

        this.db = new jTPCCConnection(conn, dbType);

        terminalMessage("");
        terminalMessage("Terminal \'" + terminalName + "\' has WarehouseID=" + terminalWarehouseID + " and DistrictID=" + terminalDistrictID + ".");
        terminalStartTime = System.currentTimeMillis();
    }

    public void run()
    {
        executeTransactions(numTransactions);
        try
        {
            printMessage("");
            printMessage("Closing statement and connection...");

            stmt.close();
            conn.close();
        }
        catch(Exception e)
        {
            printMessage("");
            printMessage("An error occurred!");
            logException(e);
        }

        printMessage("");
        printMessage("Terminal \'" + terminalName + "\' finished after " + (transactionCount-1) + " transaction(s).");

        parent.signalTerminalEnded(this, newOrderCounter);
    }

    public void stopRunningWhenPossible()
    {
        stopRunningSignal = true;
        printMessage("");
        printMessage("Terminal received stop signal!");
        printMessage("Finishing current transaction before exit...");
    }

    private void executeTransactions(int numTransactions)
    {
        boolean stopRunning = false;
        boolean reported = false;
        int transactionCount = 0;
        int newOrderCount = 0;

        if(numTransactions != -1)
            printMessage("Executing " + numTransactions + " transactions...");
        else
            printMessage("Executing for a limited time...");

        for(int i = 0; (i < numTransactions || numTransactions == -1) && !stopRunning; i++)
        {

            double transactionType = rnd.nextDouble(0, 100);
            int skippedDeliveries = 0, newOrder = 0;
            String transactionTypeName;

            long transactionStart = System.currentTimeMillis();

            /*
            * TPC/C specifies that each terminal has a fixed
            * "home" warehouse. However, since this implementation
            * does not simulate "terminals", but rather simulates
            * "application threads", that association is no longer
            * valid. In the case of having less clients than
            * warehouses (which should be the normal case), it
            * leaves the warehouses without a client without any
            * significant traffic, changing the overall database
            * access pattern significantly.
            */
            if(!terminalWarehouseFixed)
                terminalWarehouseID = sourceBegin + rnd.nextInt(1, sourceSize);

            if(transactionType <= paymentWeight)
            {
                jTPCCTData      term = new jTPCCTData();
                term.setTargetBegin(targetBegin);
                term.setTargetSize(targetSize);
                term.setWarehouse(terminalWarehouseID);
                term.setDistrict(terminalDistrictID);
                term.setPlMode(plMode);
                try
                {
                    term.generatePayment(log, rnd, 0);
                    term.traceScreen(log);
                    term.execute(log, db);
                    parent.resultAppend(term);
                    term.traceScreen(log);
                }
                catch (Exception e)
                {
                    log.fatal(e.getMessage());
                    e.printStackTrace();
                    System.exit(4);
                }
                transactionTypeName = "Payment";
            }
            else if(transactionType <= paymentWeight + stockLevelWeight)
            {
                jTPCCTData      term = new jTPCCTData();
                term.setTargetBegin(targetBegin);
                term.setTargetSize(targetSize);
                term.setWarehouse(terminalWarehouseID);
                term.setDistrict(terminalDistrictID);
                term.setPlMode(plMode);
                try
                {
                    term.generateStockLevel(log, rnd, 0);
                    term.traceScreen(log);
                    term.execute(log, db);
                    parent.resultAppend(term);
                    term.traceScreen(log);
                }
                catch (Exception e)
                {
                    log.fatal(e.getMessage());
                    e.printStackTrace();
                    System.exit(4);
                }
                transactionTypeName = "Stock-Level";
            }
            else if(transactionType <= paymentWeight + stockLevelWeight + orderStatusWeight)
            {
                jTPCCTData      term = new jTPCCTData();
                term.setTargetBegin(targetBegin);
                term.setTargetSize(targetSize);
                term.setWarehouse(terminalWarehouseID);
                term.setDistrict(terminalDistrictID);
                term.setPlMode(plMode);
                try
                {
                    term.generateOrderStatus(log, rnd, 0);
                    term.traceScreen(log);
                    term.execute(log, db);
                    parent.resultAppend(term);
                    term.traceScreen(log);
                }
                catch (Exception e)
                {
                    log.fatal(e.getMessage());
                    e.printStackTrace();
                    System.exit(4);
                }
                transactionTypeName = "Order-Status";
            }
            else if(transactionType <= paymentWeight + stockLevelWeight + orderStatusWeight + deliveryWeight)
            {
                jTPCCTData      term = new jTPCCTData();
                term.setTargetBegin(targetBegin);
                term.setTargetSize(targetSize);
                term.setWarehouse(terminalWarehouseID);
                term.setDistrict(terminalDistrictID);
                term.setPlMode(plMode);
                try
                {
                    term.generateDelivery(log, rnd, 0);
                    term.traceScreen(log);
                    term.execute(log, db);
                    parent.resultAppend(term);
                    term.traceScreen(log);

                    /*
                    * The old style driver does not have a delivery
                    * background queue, so we have to execute that
                    * part here as well.
                    */
                    jTPCCTData  bg = term.getDeliveryBG();
                    bg.traceScreen(log);
                    bg.execute(log, db);
                    parent.resultAppend(bg);
                    bg.traceScreen(log);

                    skippedDeliveries = bg.getSkippedDeliveries();
                }
                catch (Exception e)
                {
                    log.fatal(e.getMessage());
                    e.printStackTrace();
                    System.exit(4);
                }
                transactionTypeName = "Delivery";
            }
            else
            {
                jTPCCTData      term = new jTPCCTData();
                term.setTargetBegin(targetBegin);
                term.setTargetSize(targetSize);
                term.setWarehouse(terminalWarehouseID);
                term.setDistrict(terminalDistrictID);
                term.setPlMode(plMode);
                try
                {
                    term.generateNewOrder(log, rnd, 0);
                    term.traceScreen(log);
                    term.execute(log, db);
                    parent.resultAppend(term);
                    term.traceScreen(log);
                }
                catch (Exception e)
                {
                    log.fatal(e.getMessage());
                    e.printStackTrace();
                    System.exit(4);
                }
                transactionTypeName = "New-Order";

                if (bulkReportMode) {
                    newOrderCount ++;
                } else {
                    newOrder = 1;
                }
                newOrderCounter++;
            }

            if (bulkReportMode) {
                transactionCount ++;
            }

            long transactionEnd = System.currentTimeMillis();
            if (bulkReportMode) {
                if (reported) reported = false;
                if (transactionCount > 100) {
                    parent.signalTerminalEndedTransactionBulk(transactionCount, newOrderCount);
                    reported = true;
                    transactionCount = 0;
                    newOrderCount = 0;
                }
            } else {
                if(!transactionTypeName.equals("Delivery")) {
                    parent.signalTerminalEndedTransaction(this.terminalName, transactionTypeName, transactionEnd - transactionStart, null, newOrder);
                } else {
                    parent.signalTerminalEndedTransaction(this.terminalName, transactionTypeName, transactionEnd - transactionStart, (skippedDeliveries == 0 ? "None" : "" + skippedDeliveries + " delivery(ies) skipped."), newOrder);
                }	
            }

            if(limPerMin_Terminal>0){
                long elapse = transactionEnd-transactionStart;
                long timePerTx = 60000/limPerMin_Terminal;

                if(elapse<timePerTx){
                    try{
                        long sleepTime = timePerTx-elapse;
                        Thread.sleep((sleepTime));
                    }
                    catch(Exception e){
                    }
                }
            }
            if(stopRunningSignal) stopRunning = true;
        }
        if (bulkReportMode && !reported) {
            parent.signalTerminalEndedTransactionBulk(transactionCount, newOrderCount);
        }
    }


    private void error(String type) {
        log.error(terminalName + ", TERMINAL=" + terminalName + "  TYPE=" + type + "  COUNT=" + transactionCount);
        System.out.println(terminalName + ", TERMINAL=" + terminalName + "  TYPE=" + type + "  COUNT=" + transactionCount);
    }


    private void logException(Exception e)
    {
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        e.printStackTrace(printWriter);
        printWriter.close();
        log.error(stringWriter.toString());
    }


    private void terminalMessage(String message) {
        log.trace(terminalName + ", " + message);
    }


    private void printMessage(String message) {
        log.trace(terminalName + ", " + message);
    }


    void transRollback () {
        try {
            conn.rollback();
        } catch(SQLException se) {
            log.error(se.getMessage());
        }
    }


    void transCommit() {
        try {
            conn.commit();
        } catch(SQLException se) {
            log.error(se.getMessage());
            transRollback();
        }
    } // end transCommit()



}
