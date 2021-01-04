##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

class UnionFindSet(object):
    def __init__(self,size):
        self.__size=size ##number of nodes
        self.__id=[] ##id of each nodes
        self.__sz=[]#size of the components each nodes belongs to
        self.__compNum=size ##number of components

    def setIdSz(self):
        for i in range(self.__size):
            self.__id.append(i)
            self.__sz.append(1)

    def union(self,p,q):
        proot=self.find(p)
        qroot=self.find(q)

        if proot==qroot:
            return
        elif proot!=qroot:
            if self.__sz[proot] > self.__sz[qroot]:
                self.__id[qroot]=self.__id[proot]
                self.__sz[proot]=self.__sz[proot] + self.__sz[qroot]
            else:
                self.__id[proot]=self.__id[qroot]
                self.__sz[qroot]=self.__sz[qroot] + self.__id[proot]
        self.__compNum=self.__compNum-1

    def find(self,p):
        while self.__id[p]!=p:
            self.__id[p]=self.__id[self.__id[p]]
            p=self.__id[p]
        return p
    
    def count(self):
        return self.__compNum

    def isConnected(self,p,q):
        if self.find(p)==self.find(q):
            return True
        else:
            return False

    def outputIds(self):
        print(self.__id)

    def outputComponents(self):
        dtemp={}
        cnt=0

        components=[[] for i in range(self.__compNum)]
        for i in range(self.__size):
            rtemp=self.find(i)
            if (rtemp in dtemp)==False:
                dtemp[rtemp]=cnt
                components[cnt].append(i)
                #print "Debug: ", cnt, self.__compNum
                cnt=cnt+1
            else:
                components[dtemp[rtemp]].append(i)

        return components
